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
    |> output()
    |> Stream.unfold(fn
      :halted -> nil
      char -> {char, output(ascii)}
    end)
    |> to_map()
  end

  def from_input(main_program, a, b, c, visual \\ false) do
    me = self()

    opts = [
      gets: fn _prompt ->
        send(me, {:cancel_output, self()})

        receive do
          {:input, content} -> "#{content}\n"
        end
      end
    ]

    ascii =
      "test/support/puzzle17/input.txt"
      |> Intcode.read_file()
      |> (fn [_head | code] -> [2 | code] end).()
      |> IntcodeRunner.start_link(opts)

    Stream.unfold(output(ascii), fn
      nil -> nil
      other -> {other, output(ascii)}
    end)

    write_line(ascii, main_program)

    read_line(ascii)
    write_line(ascii, a)

    read_line(ascii)
    write_line(ascii, b)

    read_line(ascii)
    write_line(ascii, c)

    read_line(ascii)
    write_line(ascii, if(visual, do: "y", else: "n"))

    read_line(ascii)

    ascii
    |> output()
    |> Stream.unfold(fn
      :halted -> nil
      char -> {char, IntcodeRunner.output(ascii)}
    end)
  end

  def output(ascii) do
    receive do
      {:cancel_output, ^ascii} -> nil
      {:output, ^ascii, output} -> output
      {:halted, ^ascii} -> :halted
    end
  end

  def write_line(ascii, content) do
    :ok =
      content
      |> String.replace(" ", "")
      |> to_charlist()
      |> Enum.reduce(nil, fn char, _acc ->
        IntcodeRunner.input(ascii, char)
        :ok
      end)

    IntcodeRunner.input(ascii, ?\n)
  end

  def read_line(ascii, buffer \\ []) do
    case output(ascii) do
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
        Map.get(map, {x, y}, @space) != @scaffold ->
          acc

        Enum.all?(neighbors(x, y), fn {x, y} -> Map.get(map, {x, y}, @space) != @space end) ->
          [{x, y} | acc]

        true ->
          acc
      end
    end)
    |> Enum.reduce(0, fn {x, y}, sum -> sum + x * y end)
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
  # R12, L10, L10, L6, L12, R12, L4, R12, L10, L10, L6, L12, R12, L4, L12, R12, \
  # L6, L6, L12, R12, L4, L12, R12, L6, R12, L10, L10, L12, R12, L6, L12, R12, L6
  #
  # main A, B, A, B, C, B, C, A, C, C
  # a = R12, L10, L10
  # b = L6, L12, R12, L4
  # c = L12, R12, L6
end
