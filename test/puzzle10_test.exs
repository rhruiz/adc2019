defmodule Puzzle10Test do
  use ExUnit.Case, async: true

  import Puzzle10

  describe "vaporize/2" do
    [
      {1, {11, 12}},
      {2, {12, 1}},
      {3, {12, 2}},
      {10, {12, 8}},
      {20, {16, 0}},
      {50, {16, 9}},
      {100, {10, 16}},
      {199, {9, 6}},
      {200, {8, 2}},
      {201, {10, 9}},
      {299, {11, 1}}
    ]
    |> Enum.each(fn {limit, position} ->
      test "vaporizes #{inspect(position)} at #{limit}" do
        assert {_, unquote(position)} =
                 "test/support/puzzle10/test_input_1_4.txt"
                 |> from_file()
                 |> vaporize(unquote(limit))
      end
    end)

    test "matches requirement n" do
      assert {_, {11, 12}} =
               "test/support/puzzle10/test_input_1_4.txt" |> from_file() |> vaporize(1)
    end

    test "stops when there are no more visibles" do
      assert {299, {11, 1}} =
               "test/support/puzzle10/test_input_1_4.txt" |> from_file() |> vaporize(42_000)
    end

    test "finds the 200th asteroid to be vaporized" do
      assert {200, {x, y}} = "test/support/puzzle10/input.txt" |> from_file() |> vaporize(200)
      assert 2732 == 100 * x + y
    end
  end

  describe "best_asteroid/1" do
    test "finds the best location" do
      assert {{30, 34}, 344} = "test/support/puzzle10/input.txt" |> from_file() |> best_asteroid()
    end

    test "matches requirement 0" do
      assert {_, 8} = "test/support/puzzle10/test_input_1_0.txt" |> from_file() |> best_asteroid()
    end

    test "matches requirement 1" do
      assert {{5, 8}, 33} =
               "test/support/puzzle10/test_input_1_1.txt" |> from_file() |> best_asteroid()
    end

    test "matches requirement 2" do
      assert {{1, 2}, 35} =
               "test/support/puzzle10/test_input_1_2.txt" |> from_file() |> best_asteroid()
    end

    test "matches requirement 3" do
      assert {{6, 3}, 41} =
               "test/support/puzzle10/test_input_1_3.txt" |> from_file() |> best_asteroid()
    end

    test "matches requirement 4" do
      assert {{11, 13}, 210} =
               "test/support/puzzle10/test_input_1_4.txt" |> from_file() |> best_asteroid()
    end
  end
end
