defmodule Puzzle10Test do
  use ExUnit.Case, async: true

  import Puzzle10

  describe "best_asteroid/1" do
    test "finds  the best location" do
      assert {{34, 30}, 344} = "test/support/puzzle10/input.txt" |> from_file() |> best_asteroid()
    end

    test "matches requirement 0" do
      assert {_, 8} = "test/support/puzzle10/test_input_1_0.txt" |> from_file() |> best_asteroid()
    end

    test "matches requirement 1" do
      assert {{8, 5}, 33} =
               "test/support/puzzle10/test_input_1_1.txt" |> from_file() |> best_asteroid()
    end

    test "matches requirement 2" do
      assert {{2, 1}, 35} =
               "test/support/puzzle10/test_input_1_2.txt" |> from_file() |> best_asteroid()
    end

    test "matches requirement 3" do
      assert {{3, 6}, 41} =
               "test/support/puzzle10/test_input_1_3.txt" |> from_file() |> best_asteroid()
    end

    test "matches requirement 4" do
      assert {{13, 11}, 210} =
               "test/support/puzzle10/test_input_1_4.txt" |> from_file() |> best_asteroid()
    end
  end
end
