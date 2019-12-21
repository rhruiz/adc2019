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

  describe "from_input/5" do
    test "second star" do
      master = "A, B, A, B, C, B, C, A, C, C"
      a = "R,12,L,10,L,10"
      b = "L,6,L,12,R,12,L,4"
      c = "L,12,R,12,L,6"

      assert 1_119_775 = from_input(master, a, b, c, false) |> Enum.into([]) |> List.last()
    end
  end
end
