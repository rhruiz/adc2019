defmodule Puzzle10 do
  @moduledoc """
  Let's play asteroids
  """

  @spec from_file(Path.t()) :: map()
  def from_file(path) do
    path
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.split(&1, "", trim: true))
    |> Stream.with_index()
    |> Stream.flat_map(fn {line, x} ->
      line
      |> Enum.with_index()
      |> Enum.map(fn {content, y} -> {{x, y}, content} end)
    end)
    |> Enum.into(%{})
  end

  @spec best_asteroid(map()) :: {{integer(), integer()}, non_neg_integer()}
  def best_asteroid(map) do
    best_asteroid(map, Map.to_list(map), {{0, 0}, 0})
  end

  defp best_asteroid(_map, [], current) do
    current
  end

  defp best_asteroid(map, [{_, "."} | tail], current) do
    best_asteroid(map, tail, current)
  end

  defp best_asteroid(map, [{{x, y}, "#"} | tail], current) do
    visibles =
      for {{x2, y2}, "#"} <- Map.to_list(map), {x, y} != {x2, y2} do
        dx = x2 - x
        dy = y2 - y

        :math.atan2(dy, dx)
      end
      |> Enum.uniq()
      |> Enum.count()

    max = Enum.max_by([current, {{x, y}, visibles}], &elem(&1, 1))

    best_asteroid(map, tail, max)
  end
end
