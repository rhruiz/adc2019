defmodule Puzzle20 do
  @moduledoc """
  aMAZEing portals
  """

  @path "."
  @portal_elements Enum.into(?B..?Y, MapSet.new(), &<<&1>>)

  @inner_portal_edges {28..86, 28..88}

  def level_change({x, y}, level) do
    {xrange, yrange} = @inner_portal_edges

    if(x in xrange && y in yrange, do: level + 1, else: level - 1)
  end

  def read_file(path) do
    map =
      path
      |> File.stream!()
      |> Stream.map(&String.trim_trailing/1)
      |> Stream.with_index()
      |> Enum.reduce(%{}, fn {line, y}, map ->
        line
        |> String.split("", trim: true)
        |> Enum.with_index()
        |> Enum.reduce(map, fn {element, x}, map ->
          Map.put(map, {x, y}, element)
        end)
      end)

    portals =
      Enum.reduce(map, %{}, fn {position, element}, portals ->
        if element in @portal_elements do
          {name, inout} = portal(map, position)
          Map.update(portals, name, [inout], fn x -> [inout | x] end)
        else
          portals
        end
      end)
      |> Map.values()
      |> Enum.map(&Enum.uniq/1)
      |> Enum.flat_map(fn [%{in: i1, out: o2}, %{in: i2, out: o1}] ->
        [{i1, o1}, {i2, o2}]
      end)
      |> Enum.into(%{})

    start =
      map |> Enum.find(fn {_pos, element} -> element == "A" end) |> elem(0) |> on_maze(map, ["A"])

    exit =
      map |> Enum.find(fn {_pos, element} -> element == "Z" end) |> elem(0) |> on_maze(map, ["Z"])

    %{
      map: map,
      portals: portals,
      start: start,
      exit: exit
    }
  end

  def portal(map, position) do
    position
    |> neighbors()
    |> Enum.find(fn pos -> at(map, pos) == @path end)
    |> (fn
          nil ->
            other =
              position
              |> neighbors()
              |> Enum.find(fn pos -> at(map, pos) in @portal_elements end)

            portal(map, other)

          out ->
            other =
              position
              |> neighbors()
              |> Enum.find(fn pos -> at(map, pos) in @portal_elements end)

            name = [position, other] |> Enum.map(&at(map, &1)) |> Enum.sort()

            {name, %{in: position, out: out}}
        end).()
  end

  def neighbors({x, y}) do
    [{x + 1, y}, {x - 1, y}, {x, y + 1}, {x, y - 1}]
  end

  def at(map, pos), do: Map.get(map, pos, " ")

  def on_maze(pos, map, neighbors \\ @portal_elements) do
    Enum.find(neighbors(pos), fn pos ->
      at(map, pos) == @path
    end)
    |> Kernel.||(
      pos
      |> neighbors()
      |> Enum.find(fn pos ->
        at(map, pos) in neighbors
      end)
      |> on_maze(map)
    )
  end

  def shortest_path(maze, level_change \\ fn _, lvl -> lvl end) do
    shortest_path(maze, :queue.from_list([{maze.start, [], 0}]), MapSet.new(), level_change)
  end

  defp shortest_path(_maze, {[], []}, _visited, _fn), do: :none

  defp shortest_path(maze, queue, visited, level_change) do
    {{:value, {{x, y} = pos, route, level}}, queue} = :queue.out(queue)

    cond do
      level < 0 ->
        shortest_path(maze, queue, visited, level_change)

      wall?(maze, pos, level, level_change) ->
        # We hit a wall
        shortest_path(maze, queue, visited, level_change)

      MapSet.member?(visited, {pos, level}) ->
        # We hit a passage that was already visited in fewer steps
        shortest_path(maze, queue, visited, level_change)

      {maze.exit, 0} == {pos, level} ->
        # Yay! We found the exit
        Enum.reverse(route)

      true ->
        # We're on a passage. Go in all possible directions from here
        queue =
          :queue.in(maybe_portal(maze, level_change, level, {x + 1, y}, ["east" | route]), queue)

        queue =
          :queue.in(maybe_portal(maze, level_change, level, {x - 1, y}, ["west" | route]), queue)

        queue =
          :queue.in(maybe_portal(maze, level_change, level, {x, y + 1}, ["north" | route]), queue)

        queue =
          :queue.in(maybe_portal(maze, level_change, level, {x, y - 1}, ["south" | route]), queue)

        visited = MapSet.put(visited, {pos, level})
        shortest_path(maze, queue, visited, level_change)
    end
  end

  def maybe_portal(%{portals: portals}, level_change, level, pos, route) do
    case Map.get(portals, pos) do
      nil -> {pos, route, level}
      destination -> {destination, route, level_change.(pos, level)}
    end
  end

  def wall?(%{start: start, exit: exit}, pos, level, _)
      when level != 0 and pos in [start, exit] do
    true
  end

  def wall?(%{map: map, portals: portals}, pos, level, level_change) do
    if level == 0 && Map.get(portals, pos) && level_change.(pos, level) == -1 do
      true
    else
      at(map, pos) in ["#", " "]
    end
  end
end
