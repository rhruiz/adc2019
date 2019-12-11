defmodule Puzzle10 do
  @moduledoc """
  Let's play asteroids
  """

  def from_file(path) do
    path
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.split(&1, "", trim: true))
    |> Enum.into([])
  end

  def at(map, {x, y}), do: at(map, x, y)

  def at(map, x, y) do
   map |> Enum.at(x) |> Enum.at(y)
  end

  def best_asteroid(map) do
    best_asteroid(map, length(map), length(hd(map)))
  end

  def best_asteroid(map, rows, cols) do
    Enum.each(0..(rows - 1), fn row ->
      Enum.each(0..(cols - 1), fn col ->
        at(map, row, col) |> IO.write()
        IO.write("#{inspect {row, col}} ")
      end)
      IO.puts ""
    end)

    best_asteroid(map, rows, cols, {0, 0}, 0)
  end

  def best_asteroid(_map, rows, _, {rows, _}, current) do
    current
  end

  def best_asteroid(map, rows, cols, {x, cols}, current) do
    best_asteroid(map, rows, cols, {x + 1, 0}, current)
  end

  def best_asteroid(map, rows, cols, {x, y}, current) do
    visibles =
      for y2 <- 0..(cols - 1), x2 <- 0..(rows - 1), {x, y} != {x2, y2}, "#" == at(map, x, y), "#" == at(map, x2, y2) do
        IO.puts("testing between #{inspect {x2, y2}} and #{inspect {x, y}}")

        between(map, x2, y2, x, y)

      end
      |> List.flatten()
      |> IO.inspect(label: "#{inspect {x, y}} -> ")
      |> length()
      |> IO.inspect()

    best_asteroid(map, rows, cols, {x, y + 1}, max(current, visibles))
  end


  defp between(map, x, y2, x, y) do
    Range.new(y2, y)
    |> Enum.find([x, y2], fn
      ^y2 -> false
      ^y -> false
      y -> at(map, x, y) == "#"
    end)
  end

  defp between(map, x2, y, x, y) do
    Range.new(x2, x)
    |> Enum.find([x2, y], fn
      ^x2 -> false
      ^x -> false
      x -> at(map, x, y) == "#"
    end)
  end

  defp between(map, x2, y2, x, y) do
    mid_x = x + (x2 - x)/2
    mid_y = y + (y2 - y)/2

    if floor(mid_x) == ceil(mid_x) && floor(mid_y) == ceil(mid_y) && at(map, round(mid_x), round(mid_y)) == "#" do
      []
    else
      [{x2, y2}]
    end
  end
end
