defmodule Puzzle17 do
  @moduledoc """
  Scaffolding. Not in Rails this time.
  """

  @scaffold ?#
  @space ?.

  def from_input(patch \\ 1) do
    ascii =
      "test/support/puzzle17/input.txt"
      |> Intcode.read_file()
      |> (fn [_head | code] -> [patch | code] end).()
      |> IntcodeRunner.start_link()

    ascii
    |> IntcodeRunner.output()
    |> Stream.unfold(fn
      :halted -> nil
      char -> {char, IntcodeRunner.output(ascii)}
    end)
  end

  def read_line(ascii, buffer \\ []) do
    case IntcodeRunner.output(ascii) do
      10 -> Enum.reverse(buffer)
      code -> read_line(ascii, [code | buffer])
    end
  end

  def to_map(charlist) do
    charlist
    |> Enum.reduce({0, 0, %{}}, fn
      ?\n, {_, y, map} ->
        {0, y + 1, map}

      char, {x, y, map} ->
        {x + 1, y, Map.put(map, {x, y}, char)}
    end)
    |> elem(2)
  end

  @spec calibration(map()) :: integer()
  def calibration(map) do
    map
    |> Enum.reduce([], fn {{x, y}, _chr}, acc ->
      cond do
        Map.get(map, {x, y}, @space) != @scaffold -> acc
        Enum.all?(neighbors(x, y), fn {x, y} -> Map.get(map, {x, y}, @space) != @space end) -> [{x, y} | acc]
        true -> acc
      end
    end)
    |> Enum.reduce(0, fn {x, y},  sum -> sum + x * y end)
  end

  defp neighbors(x, y) do
    [
      {x - 1, y},
      {x, y - 1},
      {x + 1, y},
      {x, y + 1}
    ]
  end

  # solution
  # R12, L10, L10, L6, L12, R12, L4, R12, L10, L10, L6, L12, R12, L4, L12, R12, L6, L6, L12, R12, L4, L12, R12, L6, R12, L10, L10, L12, R12, L6, L12, R12, L6
  # a = R12, L10, L10
  # b = L6, L12, R12, L4
  # c = L12, R12, L6
  # A, B, A, B, C, B, C, A, C, C
end
