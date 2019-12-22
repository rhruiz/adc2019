defmodule Puzzle18 do
  @moduledoc """
  Maze solving
  """

  @all_doors ?A..?Z |> Enum.into(MapSet.new(), fn chr -> <<chr>> end)
  @all_keys ?a..?z |> Enum.into(MapSet.new(), fn chr -> <<chr>> end)
  @space "."
  @hero "@"

  def read_file(path) do
    path
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Enum.reduce({0, %{}, MapSet.new()}, fn line, {y, map, keys} ->
      line
      |> String.split("", trim: true)
      |> Enum.reduce({0, map, keys}, fn element, {x, map, keys} ->
        {x + 1, Map.put(map, {x, y}, element), add_key(keys, element)}
      end)
      |> (fn {_x, map, keys} -> {y + 1, map, keys} end).()
    end)
    |> (fn {_y, map, keys} -> {map, keys} end).()
  end

  defp add_key(keys, element) do
    if element in @all_keys do
      MapSet.put(keys, element)
    else
      keys
    end
  end

  @spec shortest_path(map(), MapSet.t()) :: integer()
  def shortest_path(maze, all_keys) do
    start_position =
      Enum.find_value(maze, fn
        {pos, "@"} -> pos
        _ -> false
      end)

    visited = MapSet.new([{start_position, MapSet.new()}])
    queue = :queue.from_list([{start_position, 0, MapSet.new()}])

    shortest_path(maze, :queue.out(queue), visited, all_keys)
  end

  defp shortest_path(_maze, {{:value, {_position, length, keys}}, _queue}, _, keys) do
    length
  end

  defp shortest_path(maze, {{:value, {position, length, keys}}, queue}, visited, all_keys) do
    {visited, queue} =
      maze
      |> neighbors(position)
      |> Enum.reduce({visited, queue}, fn neighbor, {visited, queue} ->
        visit(neighbor, Map.get(maze, neighbor), keys, length, visited, queue)
      end)

    shortest_path(maze, :queue.out(queue), visited, all_keys)
  end

  defp visit(position, value, keys, length, visited, queue) do
    cond do
      value in @all_doors and key(value) in keys ->
        visit(position, @space, keys, length, visited, queue)

      value in @all_keys ->
        keys = MapSet.put(keys, value)

        if {position, keys} in visited do
          {visited, queue}
        else
          visit(position, @space, keys, length, visited, queue)
        end

      value in [@space, @hero] and {position, keys} not in visited ->
        {MapSet.put(visited, {position, keys}), :queue.in({position, length + 1, keys}, queue)}

      true ->
        {visited, queue}
    end
  end

  defp key(door), do: String.downcase(door)

  def neighbors(map, {x, y}) do
    [{x + 1, y}, {x - 1, y}, {x, y + 1}, {x, y - 1}]
    |> Enum.filter(fn position -> Map.has_key?(map, position) end)
  end
end
