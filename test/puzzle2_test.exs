defmodule Puzzle2Test do
  use ExUnit.Case, async: true

  import Puzzle2
  import Intcode, only: [read_file: 1]

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
end
