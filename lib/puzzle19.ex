defmodule Puzzle19 do
  @moduledoc """
  Tractor beam mapping
  """

  def scan(program) do

    map =
      Enum.reduce(0..49, %{}, fn x, map ->
        Enum.reduce(0..49, map, fn y, map ->
          tractor = IntcodeRunner.start_link(program)
          IntcodeRunner.input(tractor, x)
          IntcodeRunner.input(tractor, y)

          Map.put(map, {x, y}, IntcodeRunner.output(tractor))
        end)
      end)

    Enum.reduce(map, 0, fn
      {_position, 1}, counter -> counter + 1
      _, counter -> counter
    end)
  end
end
