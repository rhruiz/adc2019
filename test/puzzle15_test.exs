defmodule Puzzle15Test do
  use ExUnit.Case, async: true

  import Puzzle15

  test "shortest route" do
    map =
      "test/support/puzzle15/input.txt"
      |> Intcode.read_file()
      |> find_oxygen_system()

    assert 318 ==
             map
             |> Puzzle15.Maze.new()
             |> Puzzle15.Solver.shortest_route()
             |> length()
  end
end
