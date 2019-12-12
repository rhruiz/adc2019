defmodule Puzzle11Test do
  use ExUnit.Case, async: true

  import Puzzle11

  describe "panels_painted/1" do
    test "returns the name of panels painted at least once" do
      assert 0 <
               "test/support/puzzle11/input.txt"
               |> Intcode.read_file()
               |> panels_painted()
    end
  end
end
