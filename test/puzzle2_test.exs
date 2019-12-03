defmodule Puzzle2Test do
  use ExUnit.Case, async: true

  import Puzzle2

  describe "from_input/1" do
    test "crashes on bad input" do
      assert_raise ArgumentError, fn ->
        from_input("test/support/puzzle2/bad_input.txt")
      end
    end

    test "runs the program on input" do
      assert [30, 1, 1, 4, 2, 5, 6, 0, 99] == from_input("test/support/puzzle2/test_input.txt")
    end
  end

  describe "find_output/1" do
    test "find_output(3101844) return {12, 2}" do
      assert {12, 2} = find_output(3_101_844)
    end

    test "finds 19690720 by default" do
      assert {84, 78} = find_output()
    end
  end

  describe "test_input/3" do
    test "test_input(input, 12, 2) returns 3101844" do
      input = read_file("test/support/puzzle2/altered_input.txt")

      assert [3_101_844 | _] = test_input(input, 12, 2)
    end
  end

  describe "run_intcode/1" do
    test "halts and catches fire on invalid opcode" do
      assert :halt_and_catch_fire = run_intcode([98])
    end

    test "1,0,0,0,99 becomes 2,0,0,0,99 (1 + 1 = 2)" do
      assert [2, 0, 0, 0, 99] == run_intcode([1, 0, 0, 0, 99])
    end

    test "2,3,0,3,99 becomes 2,3,0,6,99 (3 * 2 = 6)" do
      assert [2, 3, 0, 6, 99] == run_intcode([2, 3, 0, 3, 99])
    end

    test "2,4,4,5,99,0 becomes 2,4,4,5,99,9801 (99 * 99 = 9801)" do
      assert [2, 4, 4, 5, 99, 9801] == run_intcode([2, 4, 4, 5, 99, 0])
    end

    test "1,1,1,4,99,5,6,0,99 becomes 30,1,1,4,2,5,6,0,99" do
      assert [30, 1, 1, 4, 2, 5, 6, 0, 99] == run_intcode([1, 1, 1, 4, 99, 5, 6, 0, 99])
    end
  end
end
