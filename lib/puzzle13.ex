defmodule Puzzle13 do
  def game(opts \\ []) do
    game =
      "test/support/puzzle13/input.txt"
      |> Intcode.read_file()
      |> IntcodeRunner.start_link()

    receiver(%{}, IntcodeRunner.output(game), game, opts)
  end

  defp receiver(screen, :halted, _game, opts) do
    renderer = opts[:renderer] || (&render/1)
    renderer.(screen)
  end

  defp receiver(screen, x, game, opts) do
    y = IntcodeRunner.output(game)
    id = IntcodeRunner.output(game)

    screen
    |> Map.put({x, y}, tile(id))
    |> receiver(IntcodeRunner.output(game), game, opts)
  end

  defp render(screen) do
    {xmax, ymax} =
      Enum.reduce(screen, {0, 0}, fn {{x, y}, _}, {xmax, ymax} ->
        {max(x, xmax), max(y, ymax)}
      end)

    IO.write(IO.ANSI.clear())
    IO.write(IO.ANSI.cursor(0, 0))

    Enum.each(0..ymax, fn y ->
      Enum.map(0..xmax, fn x ->
        Map.get(screen, {x, y}, tile(0))
      end)
      |> IO.puts()
    end)

    screen
  end

  defp tile(0), do: " "
  defp tile(1), do: "#"
  defp tile(2), do: "@"
  defp tile(3), do: "-"
  defp tile(4), do: "o"
end
