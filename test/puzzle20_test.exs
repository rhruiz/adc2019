defmodule Puzzle20Test do
  use ExUnit.Case, async: true

  import Puzzle20

  test "computes shortest path with portals" do
    assert 484 =
             "test/support/puzzle20/input.txt"
             |> read_file()
             |> shortest_path()
             |> length()
  end
end
