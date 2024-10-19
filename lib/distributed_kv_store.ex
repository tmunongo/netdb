defmodule DistributedKvStore do
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

  def get(pid, key) do
    GenServer.call(pid, {:get, key})
  end

  def delete(pid, key) do
    GenServer.call(pid, {:delete, key})
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
    {:reply, :ok, %{state | store: new_store}}
  end

  def handle_info({:nodeup, node}, state) do
    Logger.info("Node #{node} joined the cluster")
    schedule_sync()
    {:noreply, state}
  end

  defp schedule_sync do
    Process.send_after(self(), :sync, @sync_interval)
  end
end
