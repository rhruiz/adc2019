defmodule Puzzle10 do
  @moduledoc """
  Let's play asteroids
  """

  @type asteroids :: map()

  @spec from_file(Path.t()) :: asteroids()
  def from_file(path) do
    path
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.split(&1, "", trim: true))
    |> Stream.with_index()
    |> Stream.flat_map(fn {line, y} ->
      line
      |> Enum.with_index()
      |> Enum.map(fn {content, x} -> {{x, y}, content} end)
    end)
    |> Enum.into(%{})
  end

  @spec vaporize(asteroids(), non_neg_integer() | :infinity) :: non_neg_integer()
  def vaporize(map, limit) do
    {position, _} = best_asteroid(map)

    vaporize(map, visibles(map, position), position, limit, nil, 0)
  end

  defp vaporize(_map, [], _position, _limit, asteroid, count) do
    {count, asteroid}
  end

  defp vaporize(_map, _visible, _position, limit, asteroid, count) when count >= limit do
    {limit, asteroid}
  end

  defp vaporize(map, visibles, position, limit, asteroid, count) do
    {new_map, new_asteroid, new_count} =
      visibles
      |> Enum.sort_by(&elem(&1, 1))
      |> Enum.reduce({map, asteroid, count}, fn
        _, acc = {_, _, count} when count >= limit ->
          acc

        {vap, _angle}, {map, _asteroid, count} ->
          {Map.put(map, vap, "x"), vap, count + 1}
      end)

    vaporize(new_map, visibles(new_map, position), position, limit, new_asteroid, new_count)
  end

  @spec best_asteroid(asteroids()) :: {{integer(), integer()}, non_neg_integer()}
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
      map
      |> visibles(x, y)
      |> Enum.uniq()
      |> Enum.count()

    max = Enum.max_by([current, {{x, y}, visibles}], &elem(&1, 1))

    best_asteroid(map, tail, max)
  end

  defp visibles(map, {x, y}), do: visibles(map, x, y)

  defp visibles(map, x, y) do
    distance_from = fn {x2, y2} ->
      :math.sqrt(:math.pow(x2 - x, 2) + :math.pow(y2 - y, 2))
    end

    for {{x2, y2}, "#"} <- Map.to_list(map), {x, y} != {x2, y2} do
      dx = x2 - x
      dy = y2 - y

      angle = fn
        n when n < 0 -> n + 2 * :math.pi()
        n -> n
      end

      {{x2, y2}, angle.(angle.(:math.atan2(dy, dx)) - 1.5 * :math.pi())}
    end
    |> Enum.group_by(&elem(&1, 1))
    |> Map.values()
    |> Enum.map(fn values ->
      values
      |> Enum.sort_by(fn {position, angle} ->
        [distance_from.(position), angle]
      end)
      |> hd()
    end)
  end
end
