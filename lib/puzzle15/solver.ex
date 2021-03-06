defmodule Puzzle15.Solver do
  @moduledoc """
  Solves the given %Maze{} using a breadth-first algorithm
  Returns the shortest route as a list of directions
  """

  alias Puzzle15.Maze

  def shortest_route(maze) do
    shortest_route(
      maze,
      :queue.in({maze.start_point, []}, :queue.new()),
      MapSet.new()
    )
  end

  # Nothing left in queue and we didn't find the exit
  defp shortest_route(_maze, {[], []}, _visited), do: :none

  defp shortest_route(maze, queue, visited) do
    {{:value, {{x, y} = pos, route}}, queue} = :queue.out(queue)

    cond do
      Maze.wall?(maze, pos) ->
        # We hit a wall
        shortest_route(maze, queue, visited)

      MapSet.member?(visited, pos) ->
        # We hit a passage that was already visited in fewer steps
        shortest_route(maze, queue, visited)

      maze.exit_point == pos ->
        # Yay! We found the exit
        Enum.reverse(route)

      true ->
        # We're on a passage. Go in all possible directions from here
        queue = :queue.in({{x + 1, y}, ["east" | route]}, queue)
        queue = :queue.in({{x - 1, y}, ["west" | route]}, queue)
        queue = :queue.in({{x, y + 1}, ["north" | route]}, queue)
        queue = :queue.in({{x, y - 1}, ["south" | route]}, queue)
        visited = MapSet.put(visited, pos)
        shortest_route(maze, queue, visited)
    end
  end
end
