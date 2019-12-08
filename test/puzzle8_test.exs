defmodule Puzzle8Test do
  use ExUnit.Case, async: true

  import Puzzle8

  describe "least_zeros/0" do
    test "matches requirement 1" do
      assert 2286 = least_zeros()
    end
  end

  describe "to_digits/3" do
    test "converts digits to layers and rows and cols" do
      assert [[[1, 2, 3], [4, 5, 6]], [[7, 8, 9], [0, 1, 2]]] =
               to_digits([1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 1, 2], 3, 2)
    end
  end
end
