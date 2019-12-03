defmodule Puzzle3 do
  @moduledoc """
  Day 3 puzzle. Messed up wires.
  """

  @type point :: {x :: integer(), y :: integer()}
  @type ortho :: -1 | 0 | 1
  @type movement :: {x :: ortho, y :: ortho, distance :: integer()}

  @doc """
  Reads a file path for both wires

  Crashes on invalid input
  """
  @spec from_input(Path.t(), atom()) :: non_neg_integer()
  def from_input(path, mode \\ :shortest_cross) do
    path
    |> File.stream!()
    |> Stream.map(&file_line_to_points/1)
    |> Enum.into([])
    |> (fn paths -> apply(__MODULE__, mode, [paths]) end).()
  end

  @spec file_line_to_points(String.t()) :: [point()]
  def file_line_to_points(line) do
    line
    |> String.split(",")
    |> Enum.map(&String.trim_trailing/1)
    |> Enum.map(&to_movement/1)
    |> path_to_points()
  end

  @spec shortest_cross([[point()]]) :: non_neg_integer()
  def shortest_cross([first_points, second_points]) do
    first_points
    |> Enum.filter(fn {point, _distance} ->
      Map.has_key?(second_points, point)
    end)
    |> Enum.sort_by(&distance_to_center/1)
    |> hd()
    |> distance_to_center()
  end

  @spec shortest_time([[point()]]) :: non_neg_integer()
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

  defp distance_to_center({{x, y}, _}), do: abs(x) + abs(y)
  defp signal_speed({signal1, signal2}), do: signal1 + signal2

  @spec path_to_points(point(), [movement()]) :: [point()]
  def path_to_points(origin \\ {0, 0}, path) do
    path
    |> Enum.reduce({{origin, 0}, Map.new()}, fn movement, {position, pointmap} ->
      apply_movement(position, movement, pointmap)
    end)
    |> elem(1)
  end

  defp apply_movement(state, {_, _, 0}, pointmap) do
    {state, pointmap}
  end

  defp apply_movement({{x, y}, steps}, {dx, dy, distance}, pointmap) do
    new_position = {x + dx, y + dy}
    steps = steps + 1

    apply_movement(
      {new_position, steps},
      {dx, dy, distance - 1},
      Map.put_new(pointmap, new_position, steps)
    )
  end

  @spec to_movement(String.t()) :: movement()
  def to_movement(<<h::binary-size(1), distance::binary>>) do
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
