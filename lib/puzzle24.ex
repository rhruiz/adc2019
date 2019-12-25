defmodule Puzzle24 do
  @moduledoc """
  Game of Life ripoff.
  """

  use Bitwise

  @space "."
  @bug "#"

  @spec read_file(Path.t()) :: map()
  def read_file(path) do
    path
    |> File.stream!()
    |> parse_lines()
  end

  def read_string(str) do
    str
    |> String.split("\n")
    |> parse_lines()
  end

  def parse_lines(lines) do
    lines
    |> Stream.map(&String.trim/1)
    |> Stream.map(fn line -> String.split(line, "", trim: true) end)
    |> Stream.with_index()
    |> Enum.reduce(%{}, fn {line, y}, map ->
      line
      |> Enum.with_index()
      |> Enum.reduce(map, fn {elem, x}, map ->
        Map.put(map, {x, y}, elem)
      end)
    end)
  end

  def biodiversity(map) do
    Enum.reduce(map, 0, fn
      {_, @space}, sum -> sum
      {{x, y}, @bug}, sum -> sum + bsl(1, y * 5 + x)
    end)
  end

  def dimensions(map) do
    Enum.reduce(map, {0, 0}, fn {{x, y}, _}, {xmax, ymax} ->
      {max(x, xmax), max(y, ymax)}
    end)
  end

  def render(game) do
    {xmax, ymax} = dimensions(game)

    Enum.each(0..ymax, fn y ->
      Enum.map(0..xmax, fn x ->
        Map.get(game, {x, y})
      end)
      |> IO.puts()
    end)
  end

  @spec simulate(map(), non_neg_integer()) :: map()
  def simulate(game, steps) do
    Enum.reduce(1..steps, game, fn _, game ->
      move(game)
    end)
  end

  def move(game) do
    Enum.into(game, %{}, fn {pos, whatis} ->
      {pos, becomes(game, whatis, pos)}
    end)
  end

  def becomes(game, @space, pos) do
    if bugs_around(game, pos) in [1, 2] do
      @bug
    else
      @space
    end
  end

  def becomes(game, @bug, pos) do
    if bugs_around(game, pos) == 1 do
      @bug
    else
      @space
    end
  end

  def bugs_around(game, pos) do
    pos
    |> neighbors()
    |> Enum.count(&(at(game, &1) == @bug))
  end

  def at(game, {x, y}) do
    Map.get(game, {x, y}, @space)
  end

  defp neighbors({x, y}) do
    [{x - 1, y}, {x + 1, y}, {x, y - 1}, {x, y + 1}]
  end
end
