# use vector clocks to handle conflicts

defmodule VectorClock do
  def new, do: %{}

  def increment(clock, node) do
    Map.update(clock, node, 1, &(&1 + 1))
  end

  def merge(clock1, clock2) do
    Map.merge(clock1, clock2, fn _k, v1, v2 -> max(v1, v2) end)
  end

  def compare(clock1, clock2) do
    cond do
      clock1 == clock2 -> :equal
      descends?(clock1, clock2) -> :descends
      descends?(clock2, clock1) -> :preceded_by
      true -> :concurrent
    end
  end

  defp descends?(clock1, clock2) do
    Enum.all?(clock2, fn {node, count} ->
      Map.get(clock1, node, 0) >= count
    end) && clock1 != clock2
  end
end
