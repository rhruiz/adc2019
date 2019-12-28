defmodule Puzzle19Test do
  use ExUnit.Case, async: true

  import Puzzle19

  describe "scan/1" do
    test "finds in a 50x50 area" do
      assert 164 =
               "test/support/puzzle19/input.txt"
               |> Intcode.read_file()
               |> scan()
    end
  end

  describe "find_square/1" do
    @tag timeout: :infinity
    test "finds where a 100x100 square fits" do
      assert {1308, 1049} =
               "test/support/puzzle19/input.txt"
               |> Intcode.read_file()
               |> find_square()
    end
  end
end
