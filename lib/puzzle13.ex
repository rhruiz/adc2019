defmodule Puzzle13 do
  @moduledoc """
  ~arkanoid~ game machine
  """

  def blocks(screen) do
    screen
    |> Enum.reduce(0, fn
      {_, "@"}, counter -> counter + 1
      _, counter -> counter
    end)
  end

  def load_game(quarters \\ 2) do
    "test/support/puzzle13/input.txt"
    |> Intcode.read_file()
    |> (fn [_ | tail] ->
          [quarters | tail]
        end).()
  end

  def game(opts \\ [], quarters \\ 2) do
    game =
      quarters
      |> load_game()
      |> IntcodeRunner.start_link(opts)

    receiver(%{}, IntcodeRunner.output(game), game, 0, opts)
  end

  defp receiver(screen, :halted, _game, score, opts) do
    {render(screen, opts), score}
  end

  defp receiver(screen, -1, game, _score, opts) do
    0 = IntcodeRunner.output(game)
    score = IntcodeRunner.output(game)

    IO.puts("score: #{score}")

    receiver(screen, IntcodeRunner.output(game), game, score, opts)
  end

  defp receiver(screen, x, game, score, opts) do
    y = IntcodeRunner.output(game)
    id = IntcodeRunner.output(game)

    screen
    |> Map.put({x, y}, tile(id))
    |> render(opts)
    |> receiver(IntcodeRunner.output(game), game, score, opts)
  end

  def render(screen, opts) do
    renderer = opts[:renderer] || (&do_render/2)

    case renderer do
      f when is_function(renderer, 2) -> f.(screen, opts)
      f when is_function(renderer, 1) -> f.(screen)
    end
  end

  defp do_render(screen, opts) do
    {xmax, ymax} =
      Enum.reduce(screen, {0, 0}, fn {{x, y}, _}, {xmax, ymax} ->
        {max(x, xmax), max(y, ymax)}
      end)

    Enum.each(0..ymax, fn y ->
      Enum.map(0..xmax, fn x ->
        Map.get(screen, {x, y}, tile(0))
      end)
      |> IO.puts()
    end)

    Process.sleep(opts[:sleep] || 0)

    screen
  end

  defp tile(0), do: " "
  defp tile(1), do: "#"
  defp tile(2), do: "@"
  defp tile(3), do: "-"
  defp tile(4), do: "o"
end
