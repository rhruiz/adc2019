defmodule Puzzle15Test do
  use ExUnit.Case, async: true

  import Puzzle15

  test "shortest route and oxygen replenishment" do
    map =
      "test/support/puzzle15/input.txt"
      |> Intcode.read_file()
      |> find_oxygen_system()

    assert 318 ==
             map
             |> Puzzle15.Maze.new()
             |> Puzzle15.Solver.shortest_route()
             |> length()

    assert 390 = Puzzle15.Replenisher.replenish(map)
  end
end
