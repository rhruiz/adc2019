defmodule Puzzle10Test do
  use ExUnit.Case, async: true

  import Puzzle10

  describe "best_asteroid/1" do
    test "matches requirement 0" do
      assert 8 = "test/support/puzzle10/test_input_1_0.txt" |> from_file() |> best_asteroid()
    end

    test "matches requirement 1" do
      assert 33 = "test/support/puzzle10/test_input_1_1.txt" |> from_file() |> best_asteroid()
    end
  end
end
