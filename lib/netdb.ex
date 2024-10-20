defmodule Netdb do
  use GenServer
  require Logger

  @sync_interval 5000

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    :net_kernel.monitor_nodes(true)
    schedule_sync()
    {:ok, %{store: %{}, vector_clock: VectorClock.new()}}
  end

  def put(pid, key, value) do
    GenServer.call(pid, {:put, key, value})
  end

  @spec get(atom() | pid() | {atom(), any()} | {:via, atom(), any()}, any()) :: any()
  def get(pid, key) do
    GenServer.call(pid, {:get, key})
  end

  def delete(pid, key) do
    GenServer.call(pid, {:delete, key})
  end

  def handle_call({:get, key}, _from, state) do
    case Map.get(state.store, key) do
      nil -> {:reply, nil, state}
      {value, _clock} -> {:reply, value, state}
    end
  end

  def handle_call({:put, key, value}, _from, state) do
    node_name = Node.self()
    new_clock = VectorClock.increment(state.vector_clock, node_name)
    new_value = {value, new_clock}
    new_store = Map.put(state.store, key, new_value)
    new_state = %{state | store: new_store, vector_clock: new_clock}
    {:reply, :ok, new_state}
  end

  def handle_call({:delete, key}, _from, state) do
    new_store = Map.delete(state.store, key)
    new_state = %{state | store: new_store}
    {:reply, :ok, new_state}
  end

  def handle_info({:nodeup, node}, state) do
    Logger.info("Node #{node} joined the cluster")
    schedule_sync()
    {:noreply, state}
  end

  def handle_info({:nodedown, node}, state) do
    Logger.info("Node #{node} has left the cluster")
    {:noreply, state}
  end

  def handle_info(:sync, state) do
    Enum.each(Node.list(), fn node ->
      GenServer.cast({__MODULE__, node}, {:sync_request, Node.self(), state.store, state.vector_clock})
    end)
    schedule_sync()
    {:noreply, state}
  end

  def handle_cast({:sync_request, from_node, remote_store, remote_clock}, state) do
    new_store = merge_stores(state.store, remote_store)
    new_clock = VectorClock.merge(state.vector_clock, remote_clock)
    GenServer.cast({__MODULE__, from_node}, {:sync_response, Node.self(), new_store, new_clock})
    {:noreply, %{state | store: new_store, vector_clock: new_clock}}
  end

  def handle_cast({:sync_response, _from_node, remote_store, remote_clock}, state) do
    new_store = merge_stores(state.store, remote_store)
    new_clock = VectorClock.merge(state.vector_clock, remote_clock)
    {:noreply, %{state | store: new_store, vector_clock: new_clock}}
  end

  defp merge_stores(local_store, remote_store) do
    Map.merge(local_store, remote_store, fn _k, {local_value, local_clock}, {remote_value, remote_clock} ->
      case VectorClock.compare(local_clock, remote_clock) do
        :descends -> {local_value, local_clock}
        :preceded_by -> {remote_value, remote_clock}
        :equal -> {local_value, local_clock}
        :concurrent -> resolve_conflict(local_value, remote_value, local_clock, remote_clock)
      end
    end)
  end

  defp resolve_conflict(local_value, remote_value, local_clock, remote_clock) do
    # use a simple "last-write-wins" strategy based on the
    # node name
    if Node.self() > hd(Node.list()) do
      {local_value, local_clock}
    else
      {remote_value, remote_clock}
    end
  end

  defp schedule_sync do
    Process.send_after(self(), :sync, @sync_interval)
  end
end
