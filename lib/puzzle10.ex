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

  def best_asteroid(map) do
    best_asteroid(map, length(map), lengh(hd(map)))
  end

  def best_asteroid(map, rows, cols) do
    best_asteriod(map, rows, cols, {0, 0}, nil)
  end

  def best_asteroid(map, rows, cols, {rows, cols}, current) do
    current
  end

  def best_asteroid(map, rows, cols, {x, cols}, current) do
    best_asteroid(map, rows, cols, {x + 1, 0}, current)
  end

  def best_asteroid(map, rows, cols, {x, y}, current) do
    for tx <- 0..rows,
        ty <- 0..cols,
        {tx, ty} != {x, y} do
    end
  end
end
