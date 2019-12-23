defmodule Puzzle20 do
  @moduledoc """
  aMAZEing portals
  """

  @path "."
  @portal_elements Enum.into(?B..?Y, MapSet.new(), &<<&1>>)

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

  def shortest_path(maze) do
    shortest_path(maze, :queue.from_list([{maze.start, []}]), MapSet.new())
  end

  defp shortest_path(_maze, {[], []}, _visited), do: :none

  defp shortest_path(maze, queue, visited) do
    {{:value, {{x, y} = pos, route}}, queue} = :queue.out(queue)

    cond do
      wall?(maze, pos) ->
        # We hit a wall
        shortest_path(maze, queue, visited)

      MapSet.member?(visited, pos) ->
        # We hit a passage that was already visited in fewer steps
        shortest_path(maze, queue, visited)

      maze.exit == pos ->
        # Yay! We found the exit
        Enum.reverse(route)

      true ->
        # We're on a passage. Go in all possible directions from here
        queue = :queue.in({maybe_portal(maze, {x + 1, y}), ["east" | route]}, queue)
        queue = :queue.in({maybe_portal(maze, {x - 1, y}), ["west" | route]}, queue)
        queue = :queue.in({maybe_portal(maze, {x, y + 1}), ["north" | route]}, queue)
        queue = :queue.in({maybe_portal(maze, {x, y - 1}), ["south" | route]}, queue)
        visited = MapSet.put(visited, pos)
        shortest_path(maze, queue, visited)
    end
  end

  def maybe_portal(%{portals: portals}, pos) do
    Map.get(portals, pos, pos)
  end

  def wall?(%{map: map}, pos) do
    at(map, pos) in ["#", " "]
  end
end
