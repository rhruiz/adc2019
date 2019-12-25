defmodule Puzzle24 do
  @moduledoc """
  Game of Life ripoff.
  """

  use Bitwise

  @space 0
  @bug 1
  @limit 5 * 5 - 1

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
    |> Enum.reduce(0, fn {line, y}, map ->
      line
      |> Enum.with_index()
      |> Enum.reduce(map, fn {elem, x}, map ->
        val = if elem == "#", do: 1, else: 0

        map ||| val <<< (5 * y + x)
      end)
    end)
  end

  def biodiversity(map), do: map

  def render(game) do
    Enum.each(0..@limit, fn i ->
      IO.write(if((game >>> i &&& 1) == 1, do: [?#], else: [?.]))

      if Integer.mod(i + 1, 5) == 0 do
        IO.write([?\n])
      end
    end)
  end

  @spec simulate(map(), non_neg_integer()) :: map()
  def simulate(game, steps) do
    Enum.reduce(1..steps, game, fn _, game ->
      move(game)
    end)
  end

  def move(game) do
    Enum.reduce(0..@limit, game, fn pos, new_game ->
      becomes = becomes(game, pos)

      (new_game &&& ~~~(1 <<< pos)) ||| becomes <<< pos
    end)
  end

  def becomes(game, pos), do: becomes(game, at(game, pos), pos)

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

  def at(game, pos) do
    game >>> pos &&& 1
  end

  def neighbors(pos) do
    line = div(pos, 5)
    h = Enum.filter([pos - 1, pos + 1], fn i -> i >= 0 && i <= @limit && div(i, 5) == line end)
    v = Enum.filter([pos - 5, pos + 5], fn i -> i >= 0 && i <= @limit end)

    h ++ v
  end
end
