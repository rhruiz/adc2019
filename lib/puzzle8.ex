defmodule Puzzle8 do
  @moduledoc """
  Pixels. Images. Elves.
  """

  def render do
    "test/support/puzzle8/input.txt"
    |> read_file()
    |> render(25, 6)
  end

  def ansi(image) do
    IO.write('\n')

    image
    |> Enum.each(fn row ->
      row
      |> Enum.map(fn
        0 -> [IO.ANSI.black_background(), " "]
        1 -> ["❖"]
      end)
      |> IO.puts()
    end)

    IO.puts(IO.ANSI.reset())
  end

  def render(input, width, height) do
    input
    |> Enum.chunk_every(width * height)
    |> Enum.reduce(fn layer, composite ->
      layer
      |> Enum.zip(composite)
      |> Enum.map(fn
        {other, 2} -> other
        {_, 0} -> 0
        {_, 1} -> 1
      end)
    end)
    |> Enum.chunk_every(width)
  end

  def least_zeros do
    "test/support/puzzle8/input.txt"
    |> read_file()
    |> to_layers(25, 6)
    |> Enum.sort_by(fn layer ->
      layer
      |> Enum.flat_map(fn layer -> layer end)
      |> Enum.reduce(0, fn
        0, count -> count + 1
        _, count -> count
      end)
    end)
    |> hd()
    |> Enum.reduce({0, 0}, fn row, acc ->
      Enum.reduce(row, acc, fn
        1, {n1, n2} -> {n1 + 1, n2}
        2, {n1, n2} -> {n1, n2 + 1}
        _, acc -> acc
      end)
    end)
    |> Tuple.to_list()
    |> Enum.reduce(&*/2)
  end

  def to_layers(digits, width, height) do
    digits
    |> Enum.chunk_every(width * height)
    |> Enum.map(fn layer -> Enum.chunk_every(layer, width) end)
  end

  def read_file(path) do
    path
    |> File.stream!([], 1)
    |> Stream.map(&String.to_integer/1)
  end
end
