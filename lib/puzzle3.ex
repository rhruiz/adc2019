defmodule Puzzle3 do
  @moduledoc """
  Day 3 puzzle. Messed up wires.
  """

  @doc """
  Reads a file path for both wires

  Crashes on invalid input
  """
  def from_input(path, mode \\ :shortest_cross) do
    path
    |> File.stream!()
    |> Stream.map(&file_line_to_points/1)
    |> Enum.into([])
    |> (fn paths ->
      apply(__MODULE__, mode, [paths])
    end).()
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
    |> Enum.filter(fn {point, _distance} ->
      Map.has_key?(second_points, point)
    end)
    |> Enum.sort_by(&distance_to_center/1)
    |> hd()
    |> distance_to_center()
  end

  def shortest_time([first_points, second_points]) do
    first_points
    |> Enum.reduce([], fn {point, steps}, acc ->
      if Map.has_key?(second_points, point) do
        [{steps, second_points[point]} | acc]
      else
        acc
      end
    end)
    |> Enum.sort_by(&signal_speed/1)
    |> hd()
    |> signal_speed()
  end

  def distance_to_center({{x, y}, _}), do: abs(x) + abs(y)
  def signal_speed({signal1, signal2}), do: signal1 + signal2

  def path_to_points(path) do
    path
    |> Enum.reduce({{{0, 0}, 0}, Map.new}, fn movement, {position, pointmap} ->
      apply_movement(position, movement, pointmap)
    end)
    |> elem(1)
  end

  def apply_movement(position, {_, _, 0}, pointmap) do
    {position, pointmap}
  end

  def apply_movement({{x, y}, steps}, {dx, dy, distance}, pointmap) do
    new_position = {x + dx, y + dy}
    steps = steps + 1
    apply_movement({new_position, steps}, {dx, dy, distance - 1}, Map.put_new(pointmap, new_position, steps))
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
