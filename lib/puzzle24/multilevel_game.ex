defmodule Puzzle24.MultilevelGame do
  @moduledoc """
  They are crazy those Plutonians.
  """

  use Bitwise

  @type level :: integer()
  @type mlgame :: %{required(level()) => Puzzle24.game()}
  @opaque position :: {level(), Puzzle24.position()}

  @center 12
  @limit 24
  @space 0
  @bug 1

  @spec move(Puzzle24.game() | mlgame, non_neg_integer()) :: mlgame()
  def move(game, steps) do
    Enum.reduce(1..steps, game, fn _, game ->
      move(game)
    end)
  end

  @spec move(Puzzle24.game() | mlgame) :: mlgame()
  def move(game) when is_map(game) do
    maxdepth = game |> Map.keys() |> Enum.max()

    game =
      game
      |> Map.put_new(maxdepth + 1, 0)
      |> Map.put_new(-maxdepth - 1, 0)

    game
    |> Map.keys()
    |> Enum.into(%{}, fn level ->
      Enum.reduce(0..@limit, {level, game[level]}, fn pos, {level, new_game} ->
        becomes = becomes(game, {level, pos})

        {level, (new_game &&& ~~~(1 <<< pos)) ||| becomes <<< pos}
      end)
    end)
  end

  def move(game), do: move(%{0 => game})

  @spec render(mlgame()) :: none()
  def render(game) do
    game
    |> Map.keys()
    |> Enum.sort()
    |> Enum.each(fn level ->
      IO.puts("Depth #{level}:")
      Puzzle24.render(game[level], %{@center => [??]})
    end)
  end

  @spec becomes(mlgame(), position()) :: Puzzle24.bug_or_space()
  defp becomes(_game, {_, @center}), do: @space

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

  @spec bugs_around(mlgame(), position()) :: non_neg_integer()
  defp bugs_around(game, pos) do
    pos
    |> neighbors()
    |> Enum.count(&(at(game, &1) == @bug))
  end

  @spec at(mlgame(), position()) :: Puzzle24.bug_or_space()
  defp at(game, {level, pos}) do
    case Map.get(game, level) do
      nil -> 0
      _other -> game[level] >>> pos &&& 1
    end
  end

  @spec neighbors(position()) :: [position()]
  defp neighbors({level, pos}) do
    line = div(pos, 5)

    h =
      Enum.flat_map([pos - 1, pos + 1], fn
        i when i < 0 or div(i, 5) < line ->
          [{level - 1, @center - 1}]

        i when div(i, 5) > line ->
          [{level - 1, @center + 1}]

        @center when pos == @center + 1 ->
          Enum.map(0..4, fn row -> {level + 1, row * 5 + 4} end)

        @center when pos == @center - 1 ->
          Enum.map(0..4, fn row -> {level + 1, row * 5} end)

        i ->
          [{level, i}]
      end)

    v =
      Enum.flat_map([pos - 5, pos + 5], fn
        i when i < 0 ->
          [{level - 1, @center - 5}]

        i when i > @limit ->
          [{level - 1, @center + 5}]

        @center when pos == @center + 5 ->
          Enum.map(0..4, fn col -> {level + 1, 4 * 5 + col} end)

        @center when pos == @center - 5 ->
          Enum.map(0..4, fn col -> {level + 1, col} end)

        i ->
          [{level, i}]
      end)

    h ++ v
  end
end
