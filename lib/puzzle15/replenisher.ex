defmodule Puzzle15.Replenisher do
  @moduledoc """
  Time to fill map with oxygen
  """

  @nothing 1
  @os 2

  @spec replenish(map()) :: non_neg_integer()
  def replenish(map) do
    replenish(map, 0, true)
  end

  defp replenish(_map, time, false), do: time

  defp replenish(map, time, true) do
    Puzzle15.render(map, {0, 0})

    new_map =
      Enum.reduce(map, map, fn
        {position, @os}, new_map ->
          position
          |> neighbors()
          |> Enum.reduce(new_map, fn pos, new_map ->
            Map.update!(new_map, pos, &oxygenate/1)
          end)

        _, new_map ->
          new_map
      end)

    replenish(new_map, time + 1, any_left?(new_map))
  end

  defp oxygenate(@nothing), do: @os
  defp oxygenate(other), do: other

  defp neighbors({x, y}) do
    [{x + 1, y}, {x - 1, y}, {x, y + 1}, {x, y - 1}]
  end

  defp any_left?(map) do
    Enum.any?(map, fn {_, t} -> t == @nothing end)
  end
end
