defmodule Puzzle3 do
  @moduledoc """
  Day 3 puzzle. Messed up wires.
  """

  @type point :: {x :: integer(), y :: integer(), distance :: non_neg_integer()}

  @doc """
  Reads a file with one integer per line representing each module mass

  Crashes on invalid input
  """
  def from_input(path) do
    path
    |> File.stream!()
    |> Stream.map(&file_line_to_points/1)
    |> Enum.into([])
    |> shortest_cross()
  end

  def file_line_to_points(line) do
    line
    |> String.split(",")
    |> Enum.map(&String.trim_trailing/1)
    |> Enum.map(&to_movement/1)
    |> path_to_points()
  end

  def shortest_cross([first_points, second_points]) do
    first_points
    |> Enum.filter(fn point ->
      MapSet.member?(second_points, point)
    end)
    |> Enum.sort_by(&distance_to_center/1)
    |> hd()
    |> distance_to_center()
  end

  def distance_to_center({x, y}), do: abs(x) + abs(y)

  def path_to_points(path) do
    path
    |> Enum.reduce({{0, 0}, MapSet.new}, fn movement, {position, pointmap} ->
      apply_movement(position, movement, pointmap)
    end)
    |> elem(1)
  end

  def apply_movement(position, {_, _, 0}, pointmap) do
    {position, pointmap}
  end

  def apply_movement({x, y}, {dx, dy, distance}, pointmap) do
    new_position = {x + dx, y + dy}
    apply_movement(new_position, {dx, dy, distance - 1}, MapSet.put(pointmap, new_position))
  end

  def to_movement(<< h :: binary-size(1), distance :: binary >>) do
    to_movement(direction(h), String.to_integer(distance))
  end

  defp to_movement({x, y}, distance) do
    {x, y, distance}
  end

  defp direction("U"), do: {0, 1}
  defp direction("D"), do: {0, -1}
  defp direction("L"), do: {-1, 0}
  defp direction("R"), do: {1, 0}
end
