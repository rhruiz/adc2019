defmodule Puzzle24.MultilevelGameTest do
  use ExUnit.Case, async: true

  import Puzzle24, only: [read_file: 1]
  import Puzzle24.MultilevelGame

  describe "move/2" do
    test "with test input has 99 bugs after 10 moves" do
      assert 99 =
               "test/support/puzzle24/test_input_1.txt"
               |> read_file()
               |> move(10)
               |> Enum.reduce(0, fn {_level, game}, count ->
                 game
                 |> Integer.to_string(2)
                 |> String.graphemes()
                 |> Enum.count(fn bin -> bin == "1" end)
                 |> Kernel.+(count)
               end)
    end

    test "with input after 200 moves" do
      assert 1937 =
               "test/support/puzzle24/input.txt"
               |> read_file()
               |> move(200)
               |> Enum.reduce(0, fn {_level, game}, count ->
                 game
                 |> Integer.to_string(2)
                 |> String.graphemes()
                 |> Enum.count(fn bin -> bin == "1" end)
                 |> Kernel.+(count)
               end)
    end
  end
end
