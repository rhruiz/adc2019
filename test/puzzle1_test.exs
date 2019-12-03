defmodule Puzzle1Test do
  use ExUnit.Case, async: true

  import Puzzle1

  describe "from_input/1" do
    test "computes fuel for modules" do
      assert 4892166 = from_input("test/support/puzzle1/input.txt")
    end

    test "reads module masses from file" do
      assert 2 + 2 + 966 + 50346 ==
               from_input("test/support/puzzle1/fuel.txt")
    end

    test "booms on invalid input" do
      assert_raise ArgumentError, fn ->
        from_input("test/support/puzzle1/invalid.txt")
      end
    end
  end

  describe "total_fuel/1" do
    test "no modules, no fuel" do
      assert total_fuel([]) == 0
    end

    test "verify requirements" do
      assert 2 + 2 + 966 + 50346 ==
               total_fuel([12, 14, 1969, 100_756])
    end

    test "a mass of 12 requires 2 fuel" do
      assert total_fuel([12]) == 2
    end

    test "a mass of 24 requires 4 fuel" do
      assert total_fuel([12, 12]) == 4
    end

    test "a mass of 14 requires 2 fuel" do
      assert total_fuel([14]) == 2
    end

    test "a mass of 1969 requires 654 fuel" do
      assert total_fuel([1969]) == 966
    end

    test "a mass of 100756 requires 33583 fuel" do
      assert total_fuel([100_756]) == 50346
    end
  end

  describe "fuel/1" do
    test "negative fuel requirement is 0 fuel" do
      assert fuel(1) == 0
      assert fuel(3) == 0
      assert fuel(4) == 0
      assert fuel(6) == 0
    end

    test "a mass of 12 requires 2 fuel" do
      assert fuel(12) == 2
    end

    test "a mass of 14 requires 2 fuel" do
      assert fuel(14) == 2
    end

    test "a mass of 1969 requires 654 fuel" do
      assert fuel(1969) == 654
    end

    test "a mass of 100756 requires 33583 fuel" do
      assert fuel(100_756) == 33583
    end
  end
end
