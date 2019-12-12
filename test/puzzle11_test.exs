defmodule Puzzle11Test do
  use ExUnit.Case, async: true

  import Puzzle11

  describe "draw/1" do
    test "renders license" do
      "test/support/puzzle11/input.txt"
      |> Intcode.read_file()
      |> panels_painted(1)
      |> draw()
    end
  end

  describe "panels_painted/1" do
    test "paints with inital white panel" do
      "test/support/puzzle11/input.txt"
      |> Intcode.read_file()
      |> panels_painted(1)
    end

    test "returns panels panels painted at least once" do
      assert 2469 =
               "test/support/puzzle11/input.txt"
               |> Intcode.read_file()
               |> panels_painted()
               |> Map.keys()
               |> length()
    end
  end
end
