defmodule Puzzle7Test do
  use ExUnit.Case, async: true

  import Puzzle7

  describe "find_max_output/1" do
    test "finds the max" do
      assert 17_790 = find_max_output()
    end

    test "matches requirement 1" do
      assert 43_210 =
               find_max_output([3, 15, 3, 16, 1002, 16, 10, 16, 1, 16, 15, 15, 4, 15, 99, 0, 0])
    end

    test "matches requirement 2" do
      assert 54_321 =
               find_max_output([
                 3,
                 23,
                 3,
                 24,
                 1002,
                 24,
                 10,
                 24,
                 1002,
                 23,
                 -1,
                 23,
                 101,
                 5,
                 23,
                 23,
                 1,
                 24,
                 23,
                 23,
                 4,
                 23,
                 99,
                 0,
                 0
               ])
    end

    test "matches requirement 3" do
      assert 65_210 =
               find_max_output([
                 3,
                 31,
                 3,
                 32,
                 1002,
                 32,
                 10,
                 32,
                 1001,
                 31,
                 -2,
                 31,
                 1007,
                 31,
                 0,
                 33,
                 1002,
                 33,
                 7,
                 33,
                 1,
                 33,
                 31,
                 31,
                 1,
                 32,
                 31,
                 31,
                 4,
                 31,
                 99,
                 0,
                 0,
                 0
               ])
    end
  end

  describe "test_phase_sequence/2" do
    test "matches requirement 1" do
      assert 43_210 =
               test_phase_sequence([4, 3, 2, 1, 0], [
                 3,
                 15,
                 3,
                 16,
                 1002,
                 16,
                 10,
                 16,
                 1,
                 16,
                 15,
                 15,
                 4,
                 15,
                 99,
                 0,
                 0
               ])
    end

    test "matches requirement 2" do
      assert 54_321 =
               test_phase_sequence([0, 1, 2, 3, 4], [
                 3,
                 23,
                 3,
                 24,
                 1002,
                 24,
                 10,
                 24,
                 1002,
                 23,
                 -1,
                 23,
                 101,
                 5,
                 23,
                 23,
                 1,
                 24,
                 23,
                 23,
                 4,
                 23,
                 99,
                 0,
                 0
               ])
    end

    test "matches requirement 3" do
      assert 65_210 =
               test_phase_sequence([1, 0, 4, 3, 2], [
                 3,
                 31,
                 3,
                 32,
                 1002,
                 32,
                 10,
                 32,
                 1001,
                 31,
                 -2,
                 31,
                 1007,
                 31,
                 0,
                 33,
                 1002,
                 33,
                 7,
                 33,
                 1,
                 33,
                 31,
                 31,
                 1,
                 32,
                 31,
                 31,
                 4,
                 31,
                 99,
                 0,
                 0,
                 0
               ])
    end
  end
end
