defmodule Puzzle15 do
  @moduledoc """
  Repair droid control program
  """

  @type position :: {integer(), integer()}

  @wall 0
  @nothing 1
  @os 2
  @unknown -1

  @n 1
  @s 2
  @w 3
  @e 4

  defp tile(@wall), do: "#"
  defp tile(@nothing), do: "."
  defp tile(@os), do: "O"
  defp tile(@unknown), do: "?"

  def render(map, position) do
    {xmax, xmin, ymax, ymin} =
      Enum.reduce(map, {0, 0, 0, 0}, fn {{x, y}, _}, {xmax, xmin, ymax, ymin} ->
        {max(x, xmax), min(x, xmin), max(y, ymax), min(y, ymin)}
      end)

    Enum.each(ymin..ymax, fn y ->
      Enum.map(xmin..xmax, fn x ->
        case {x, y} do
          ^position -> "D"
          {0, 0} -> "X"
          _ -> map |> Map.get({x, y}, @unknown) |> tile()
        end
      end)
      |> IO.puts()
    end)
  end

  @spec find_oxygen_system(Intcode.t()) :: {map(), position()}
  def find_oxygen_system(program) do
    droid = IntcodeRunner.start_link(program)

    position = {0, 0}
    find_oxygen_system(droid, [position], %{})
  end

  defp at(map, position), do: Map.get(map, position, @unknown)

  def find_oxygen_system(_droid, [], map) do
    map
  end

  def find_oxygen_system(droid, [position | queue], map) do
    IO.inspect(position, label: "testing")

    {new_map, queue} =
      directions()
      |> Enum.reduce({map, queue}, fn direction, {map, queue} ->
        new_position = moved(position, direction)

        if at(map, new_position) == @unknown do
          case move(droid, position, direction, map) do
            {^position, @wall, new_map} ->
              {new_map, queue}

            {new_position, _found, new_map} ->
              {^position, _, _} = move(droid, new_position, reverse(direction), new_map)
              {new_map, [new_position | queue]}
          end
        else
          {map, queue}
        end
      end)

    find_oxygen_system(droid, queue, new_map)
  end

  defp directions, do: [@n, @s, @w, @e]

  def move(droid, position, direction, map) when direction in [@n, @s, @w, @e]  do
    IntcodeRunner.input(droid, direction)
    new_position = moved(position, direction)

    case IntcodeRunner.output(droid) do
      @wall ->
        {position, @wall, Map.put(map, new_position, @wall)}

      @nothing ->
        {new_position, @nothing, Map.put(map, new_position, @nothing)}

      @os ->
        {new_position, @os, Map.put(map, new_position, @os)}
    end
  end

  defp moved({x, y}, {dx, dy}) do
    {x + dx, y + dy}
  end

  defp moved(position, direction) do
    moved(position, to_movement(direction))
  end

  defp reverse(@n), do: @s
  defp reverse(@s), do: @n
  defp reverse(@w), do: @e
  defp reverse(@e), do: @w

  defp to_movement(@n), do: {0, -1}
  defp to_movement(@s), do: {0, 1}
  defp to_movement(@e), do: {1, 0}
  defp to_movement(@w), do: {-1, 0}
end
