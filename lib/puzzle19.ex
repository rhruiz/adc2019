defmodule Puzzle19 do
  @moduledoc """
  Tractor beam mapping
  """

  def scan(program) do
    0..49
    |> Enum.reduce(0, fn x, counter ->
      Enum.reduce(0..49, counter, fn y, counter ->
        counter + at(program, x, y)
      end)
    end)
  end

  defp at(program, x, y) do
    tractor = IntcodeRunner.start_link(program)
    IntcodeRunner.input(tractor, x)
    IntcodeRunner.input(tractor, y)

    IntcodeRunner.output(tractor)
  end

  defp seq(initial), do: Stream.unfold(initial, fn n -> {n, n + 1} end)

  def find_square(program) do
    seq(100)
    |> Stream.transform(0, fn y, lastx ->
      x1 =
        lastx
        |> seq()
        |> Enum.find(fn x -> at(program, x, y) == 1 end)

      if at(program, x1 + 99, y) == 1 do
        x2 =
          x1
          |> seq()
          |> Enum.find(fn x -> at(program, x + 99, y) == 0 end)
          |> Kernel.-(1)

        Enum.find(x1..x2, fn x ->
          at(program, x, y + 99) == 1 && at(program, x + 99, y + 99) == 1
        end)
        |> (fn
              nil -> {[], x1}
              x -> {[{x, y}], x1}
            end).()
      else
        {[], x1}
      end
    end)
    |> Stream.take(1)
    |> Enum.min_by(fn {x, y} -> x + y end)
  end
end
