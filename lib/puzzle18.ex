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
    start_positions =
      Enum.flat_map(maze, fn
        {pos, "@"} -> [pos]
        _ -> []
      end)

    visited = Enum.reduce(start_positions, MapSet.new(), fn pos, acc -> MapSet.put(acc, [{pos, MapSet.new()}]) end)

    queue =
      if length(start_positions) > 1 do
        start_positions
        |> Enum.map(fn pos -> {pos, start_positions -- [pos], 0, MapSet.new()} end)
        |> :queue.from_list()
      else
        start_positions
        |> Enum.map(fn pos -> {pos, 0, MapSet.new()} end)
        |> :queue.from_list()
      end

    shortest_path(maze, :queue.out(queue), visited, all_keys)
  end

  defp shortest_path(_maze, {{:value, {_position, length, keys}}, _}, _, keys) do
    length
  end

  defp shortest_path(_maze, {{:value, {_position, _rest, length, keys}}, _}, _, keys) do
    length
  end

  defp shortest_path(maze, {{:value, {position, rest, length, keys}}, queue}, visited, all_keys) do
    {visited, queue} =
      maze
      |> neighbors(position)
      |> Enum.reduce({visited, queue}, fn neighbor, {visited, queue} ->
        visit(neighbor, Map.get(maze, neighbor), rest, keys, length, visited, queue)
      end)

    shortest_path(maze, :queue.out(queue), visited, all_keys)
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

  defp visit(position, value, rest, keys, length, visited, queue) do
    cond do
      {position, keys} in visited ->
        {visited, queue}

      value in @all_doors and key(value) not in keys ->
        {visited, queue}

      true ->
        keys = add_key(keys, value)
        multi_move(keys, visited, queue, position, rest, length)
    end
  end

  defp multi_move(keys, visited, queue, position, rest, length) do
    all = [position | rest]

    all
    |> Enum.with_index()
    |> Enum.reduce({visited, queue}, fn
      {pos, 0}, {visited, queue} ->
        if {pos, keys} not in visited do
          {MapSet.put(visited, {pos, keys}), :queue.in({pos, rest, length + 1, keys}, queue)}
        else
          {visited, queue}
        end

      {pos, idx}, {visited, queue} ->
        if {pos, keys} not in visited do
          {left, [^pos | tr]} = Enum.split(rest, idx - 1)
          rest = left ++ [position] ++ tr

          {MapSet.put(visited, {pos, keys}), :queue.in({pos, rest, length + 1, keys}, queue)}
        else
          {visited, queue}
        end
    end)
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
