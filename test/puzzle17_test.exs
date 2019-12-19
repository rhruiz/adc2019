defmodule Puzzle17Test do
  use ExUnit.Case, async: true

  import Puzzle17

  describe "calibration/1" do
    test "is 76 for test data" do
      assert 76 =
        "test/support/puzzle17/test_input.txt"
        |> File.read!()
        |> String.to_charlist()
        |> to_map()
        |> calibration()
    end

    test "with input" do
      assert 8084 = from_input() |> calibration()
    end
  end
end
