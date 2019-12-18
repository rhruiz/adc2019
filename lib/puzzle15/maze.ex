defmodule Puzzle15.Maze do
  @moduledoc """
  Maze representation for finding the optimial solution path
  """

  defstruct(
    width: 0,
    height: 0,
    start_point: {0, 0},
    exit_point: {0, 0},
    points: %{}
  )

  def wall?(%__MODULE__{width: width}, {x, _}) when x < 0 or width <= x, do: true
  def wall?(%__MODULE__{height: height}, {_, y}) when y < 0 or height <= y, do: true
  def wall?(maze, point) do
    Map.get(maze.points, point, 0) in [0, -1]
  end

  def new(points) do
    {xmax, xmin, ymax, ymin} = Puzzle15.dimensions(points)
    width = xmax - xmin
    height = ymax - ymin

    translate = fn {{x, y}, value} -> {{x - xmin, y - ymin}, value} end
    points = points
             |> Enum.map(translate)
             |> Enum.into(%{})

   exit_point = Enum.find_value(points, fn
      {point, 2} -> point
      _ -> false
    end)

    start_point = {{0, 0}, "X"} |> translate.() |> elem(0)

    %__MODULE__{points: points, start_point: start_point, exit_point: exit_point, width: width, height: height}
  end
end
