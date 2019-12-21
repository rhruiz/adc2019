defmodule Puzzle15 do
  @moduledoc """
  Repair droid control program
  """

  @type position :: {integer(), integer()}

  @wall 0
  @nothing 1
  @os 2

  @n 1
  @s 2
  @w 3
  @e 4

  @directions [@n, @s, @w, @e]

  @clockwise %{
    @n => @e,
    @e => @s,
    @s => @w,
    @w => @n
  }

  @counterclock %{
    @n => @w,
    @w => @s,
    @s => @e,
    @e => @n
  }

  def dimensions(map) do
    Enum.reduce(map, {0, 0, 0, 0}, fn {{x, y}, _}, {xmax, xmin, ymax, ymin} ->
      {max(x, xmax), min(x, xmin), max(y, ymax), min(y, ymin)}
    end)
  end

  if Mix.env() == :test do
    def render(map, _position), do: map
  else
    @unknown -1

    defp tile(@wall), do: "#"
    defp tile(@nothing), do: "."
    defp tile(@os), do: "O"
    defp tile(@unknown), do: "?"

    def render(map, position) do
      {xmax, xmin, ymax, ymin} = dimensions(map)
      IO.puts(IO.ANSI.clear())

      for y <- ymin..ymax, x <- xmin..xmax do
        case {x, y} do
          ^position -> "D"
          {0, 0} -> "X"
          {^xmax, _} = pos -> [Map.get(map, pos, @unknown) |> tile(), "\n"]
          _ -> map |> Map.get({x, y}, @unknown) |> tile()
        end
      end
      |> IO.puts()

      Process.sleep(5)
    end
  end

  @spec find_oxygen_system(Intcode.t()) :: {map(), position()}
  def find_oxygen_system(program) do
    droid = IntcodeRunner.start_link(program)

    position = {0, 0}
    map = %{position => @nothing}
    next = @clockwise[@n]
    find_oxygen_system(droid, {position, next}, map)
  end

  def find_oxygen_system(_droid, {{0, 0}, @s}, map) do
    map
  end

  def find_oxygen_system(droid, {position, direction}, map) do
    render(map, position)

    case move(droid, position, direction, map) do
      {^position, @wall, new_map} ->
        find_oxygen_system(droid, {position, @counterclock[direction]}, new_map)

      {new_position, _found, new_map} ->
        find_oxygen_system(droid, {new_position, @clockwise[direction]}, new_map)
    end
  end

  def move(droid, position, direction, map) when direction in @directions do
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

  defp to_movement(@n), do: {0, -1}
  defp to_movement(@s), do: {0, 1}
  defp to_movement(@e), do: {1, 0}
  defp to_movement(@w), do: {-1, 0}
end
