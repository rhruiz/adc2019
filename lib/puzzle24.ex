defmodule Puzzle24 do
  @moduledoc """
  Game of Life ripoff.
  """

  use Bitwise

  @space 0
  @bug 1
  @limit 5 * 5 - 1

  @opaque game :: integer()
  @opaque bug_or_space :: 0 | 1
  @opaque position :: integer()

  @spec read_file(Path.t()) :: game()
  def read_file(path) do
    path
    |> File.stream!()
    |> parse_lines()
  end

  @spec read_string(String.t()) :: game()
  def read_string(str) do
    str
    |> String.split("\n")
    |> parse_lines()
  end

  @spec parse_lines(Enumerable.t()) :: game()
  defp parse_lines(lines) do
    lines
    |> Stream.map(&String.trim/1)
    |> Stream.flat_map(fn line -> String.split(line, "", trim: true) end)
    |> Stream.reject(fn chr -> chr == "\n" end)
    |> Stream.with_index()
    |> Enum.reduce(0, fn {elem, pos}, map ->
      val = if elem == "#", do: 1, else: 0
      map ||| val <<< pos
    end)
  end

  @spec biodiversity(game()) :: integer()
  def biodiversity(map), do: map

  @spec render(game()) :: none()
  def render(game) do
    Enum.each(0..@limit, fn i ->
      IO.write(if((game >>> i &&& 1) == 1, do: [?#], else: [?.]))

      if Integer.mod(i + 1, 5) == 0 do
        IO.write([?\n])
      end
    end)
  end

  @spec move(game(), non_neg_integer()) :: game()
  def move(game, steps) do
    Enum.reduce(1..steps, game, fn _, game ->
      move(game)
    end)
  end

  @spec move(game()) :: game()
  def move(game) do
    Enum.reduce(0..@limit, game, fn pos, new_game ->
      becomes = becomes(game, pos)

      (new_game &&& ~~~(1 <<< pos)) ||| becomes <<< pos
    end)
  end

  @spec becomes(game(), position()) :: bug_or_space()
  defp becomes(game, pos), do: becomes(game, at(game, pos), pos)

  defp becomes(game, @space, pos) do
    if bugs_around(game, pos) in [1, 2] do
      @bug
    else
      @space
    end
  end

  defp becomes(game, @bug, pos) do
    if bugs_around(game, pos) == 1 do
      @bug
    else
      @space
    end
  end

  @spec bugs_around(game(), position()) :: non_neg_integer()
  defp bugs_around(game, pos) do
    pos
    |> neighbors()
    |> Enum.count(&(at(game, &1) == @bug))
  end

  @spec at(game(), position()) :: bug_or_space()
  defp at(game, pos) do
    game >>> pos &&& 1
  end

  @spec neighbors(position()) :: [position()]
  defp neighbors(pos) do
    line = div(pos, 5)
    h = Enum.filter([pos - 1, pos + 1], fn i -> i >= 0 && i <= @limit && div(i, 5) == line end)
    v = Enum.filter([pos - 5, pos + 5], fn i -> i >= 0 && i <= @limit end)

    h ++ v
  end
end
