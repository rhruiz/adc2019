defmodule Puzzle11 do
  @moduledoc """
  Painting license panels
  """

  @spec draw(map()) :: none()
  def draw(panels) do
    IO.write("\n")

    {xrange, yrange} =
      panels
      |> Map.keys()
      |> (fn keys ->
            x = fn {x, _} -> x end
            y = fn {_, y} -> y end

            {
              Range.new(x.(Enum.min_by(keys, x)), x.(Enum.max_by(keys, x))),
              Range.new(y.(Enum.min_by(keys, y)), y.(Enum.max_by(keys, y)))
            }
          end).()

    for y <- yrange,
        x <- Stream.concat(xrange, ["\n"]) do
      case {x, Map.get(panels, {x, y}, 0)} do
        {"\n", _} -> ["\n"]
        {_, 0} -> [IO.ANSI.black_background(), " "]
        {_, 1} -> ["❖"]
      end
    end
    |> IO.puts()

    IO.puts(IO.ANSI.reset())
  end

  @spec panels_painted(Intcode.t(), 0 | 1) :: map()
  def panels_painted(program, color \\ 0) do
    runner = IntcodeRunner.start_link(program)
    position = {0, 0, :up}
    panels = %{}

    panels_painted(runner, panels, position, color)
  end

  defp panels_painted(runner, panels, position, color) do
    case paint(runner, position, color) do
      {new_color, new_position} ->
        panels_painted(
          runner,
          set_color(panels, position, new_color),
          new_position,
          color(panels, new_position)
        )

      :halted ->
        panels
    end
  end

  defp color(panels, {x, y, _}) do
    Map.get(panels, {x, y}, 0)
  end

  defp set_color(panels, {x, y, _}, color) do
    Map.put(panels, {x, y}, color)
  end

  defp paint(runner, position, color) do
    IntcodeRunner.input(runner, color)

    with color when color != :halted <- IntcodeRunner.output(runner),
         movement <- IntcodeRunner.output(runner) do
      {color, apply_movement(position, movement)}
    end
  end

  defp apply_movement({x, y, _facing}, {dx, dy, facing}), do: {x + dx, y + dy, facing}

  defp apply_movement({_x, _y, facing} = position, moviment) do
    apply_movement(position, moviment(facing, moviment))
  end

  defp moviment(:left, 0), do: {0, 1, :down}
  defp moviment(:left, 1), do: {0, -1, :up}
  defp moviment(:down, 0), do: {1, 0, :right}
  defp moviment(:down, 1), do: {-1, 0, :left}
  defp moviment(:up, 0), do: {-1, 0, :left}
  defp moviment(:up, 1), do: {1, 0, :right}
  defp moviment(:right, 0), do: {0, -1, :up}
  defp moviment(:right, 1), do: {0, 1, :down}
end
