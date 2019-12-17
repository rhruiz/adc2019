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

  @directions [@n, @s, @w, @e]

  defp tile(@wall), do: "#"
  defp tile(@nothing), do: "."
  defp tile(@os), do: "O"
  defp tile(@unknown), do: "?"

  defp dimensions(map) do
    Enum.reduce(map, {0, 0, 0, 0}, fn {{x, y}, _}, {xmax, xmin, ymax, ymin} ->
      {max(x, xmax), min(x, xmin), max(y, ymax), min(y, ymin)}
    end)
  end

  def render(map, position) do
    {xmax, xmin, ymax, ymin} = dimensions(map)
    # IO.puts(IO.ANSI.clear())

    Enum.flat_map(ymin..ymax, fn y ->
      Enum.map(xmin..xmax, fn x ->
        case {x, y} do
          ^position -> "D"
          {0, 0} -> "X"
          _ -> map |> Map.get({x, y}, @unknown) |> tile()
        end
      end)
      |> Stream.concat(["\n"])
    end)
    |> IO.puts()

    Process.sleep(10)
  end

  defp next_move(map, position) do
    {position,
      Enum.find(@directions, fn direction ->
        !Map.has_key?(map, moved(position, direction))
      end)
    }
  end

  @spec find_oxygen_system(Intcode.t()) :: {map(), position()}
  def find_oxygen_system(program) do
    droid = IntcodeRunner.start_link(program)

    position = {0, 0}
    map = %{position => @nothing}
    next = next_move(map, position)
    find_oxygen_system(droid, next, map, [])
  end

  defp backtrack(_droid, position, map, []) do
    render(map, position)
    map
  end

  defp backtrack(droid, position, map, [fallback | fb]) do
    render(map, position)

    case next_move(map, position) do
      {_, nil} ->
        {new_position, _found, new_map} = move(droid, position, reverse(fallback), map)
        IO.puts "no options out of #{inspect position}, backtrack back using #{reverse(fallback)}"
        backtrack(droid, new_position, new_map, fb)

      movement ->
        IO.puts("moving to #{inspect movement}")
        find_oxygen_system(droid, movement, map, fb)
    end
  end

  def find_oxygen_system(droid, {position, nil}, map, fallback) do
    render(map, position)
    backtrack(droid, position, map, fallback)
  end

  # def find_oxygen_system(droid, {position, nil}, map, fallback) do
  #   IO.puts("using random fallback to leave #{inspect position}")
  #   {xmax, xmin, ymax, ymin} = dimensions(map)

  #   continue = abs(xmax - xmin) < 41 || abs(ymax - ymin) < 41 || !Enum.find(false, map, fn
  #     {_, @os} -> true
  #     _ -> false
  #   end)

  #   continue(continue, droid, {position, Enum.random(@directions)}, map, fallback)
  # end

  def find_oxygen_system(droid, {position, direction}, map, fallback) do
    render(map, position)

    case move(droid, position, direction, map) do
      {^position, _found, new_map} ->
        find_oxygen_system(droid, next_move(new_map, position), new_map, fallback)

      {new_position, _found, new_map} ->
        find_oxygen_system(droid, next_move(new_map, new_position), new_map, [direction | fallback])
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

  defp reverse(@n), do: @s
  defp reverse(@s), do: @n
  defp reverse(@w), do: @e
  defp reverse(@e), do: @w

  defp to_movement(@n), do: {0, -1}
  defp to_movement(@s), do: {0, 1}
  defp to_movement(@e), do: {1, 0}
  defp to_movement(@w), do: {-1, 0}
end
