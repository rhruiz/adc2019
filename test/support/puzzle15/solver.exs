defmodule Maze do
  defstruct(
    width: 0,
    height: 0,
    start_point: {0, 0},
    exit_point: {0, 0},
    points: %{}
  )

  def wall?(%Maze{width: width}, {x, _}) when x < 0 or width <= x, do: true
  def wall?(%Maze{height: height}, {_, y}) when y < 0 or height <= y, do: true
  def wall?(maze, point) do
    Map.get(maze.points, point, "#") in ["#", "?"]
  end

  def parse do
    points =
      File.stream!("map3.txt")
      |> Stream.map(&String.trim/1)
      |> Stream.map(fn line -> String.split(line, "", trim: true) |> Enum.with_index() end)
      |> Stream.with_index()
      |> Stream.flat_map(fn {line, y} ->
        Enum.map(line, fn {element, x} ->
          {{x, y}, element}
        end)
      end)
      |> Enum.into(%{})


    width = ceil(:math.sqrt(Enum.reduce(points, 0, fn _, count -> count + 1 end)))
    height = width

   exit_point = Enum.find_value(points, fn
      {point, "O"} -> point
      _ -> false
    end)

    start_point = Enum.find_value(points, fn
      {point, "X"} -> point
      _ -> false
    end)

    %Maze{points: points, start_point: start_point, exit_point: exit_point, width: width, height: height}
  end
end

defmodule Maze.Solver do
  @doc """
  Solves the given %Maze{} using a breadth-first algorithm
  Returns the shortest route as a list of directions
  """
  def shortest_route(maze) do
    shortest_route(
      maze,
      :queue.in({maze.start_point, []}, :queue.new),
      MapSet.new
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


Maze.parse |> IO.inspect |> Maze.Solver.shortest_route() |> IO.inspect |> length |> IO.inspect
