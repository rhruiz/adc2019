defmodule Puzzle7Test do
  use ExUnit.Case, async: true

  import Puzzle7

  describe "find_max_output_with_feedback_loop/1" do
    test "finds the max output" do
      assert 19_384_820 = find_max_output_with_feedback_loop()
    end
  end

  describe "run_feedback_loop/2" do
    test "matches requirement 1" do
      assert 139_629_729 =
               run_feedback_loop([9, 8, 7, 6, 5], [
                 3,
                 26,
                 1001,
                 26,
                 -4,
                 26,
                 3,
                 27,
                 1002,
                 27,
                 2,
                 27,
                 1,
                 27,
                 26,
                 27,
                 4,
                 27,
                 1001,
                 28,
                 -1,
                 28,
                 1005,
                 28,
                 6,
                 99,
                 0,
                 0,
                 5
               ])
    end

    test "matches requirement 2" do
      assert 18_216 =
               run_feedback_loop([9, 7, 8, 5, 6], [
                 3,
                 52,
                 1001,
                 52,
                 -5,
                 52,
                 3,
                 53,
                 1,
                 52,
                 56,
                 54,
                 1007,
                 54,
                 5,
                 55,
                 1005,
                 55,
                 26,
                 1001,
                 54,
                 -5,
                 54,
                 1105,
                 1,
                 12,
                 1,
                 53,
                 54,
                 53,
                 1008,
                 54,
                 0,
                 55,
                 1001,
                 55,
                 1,
                 55,
                 2,
                 53,
                 55,
                 53,
                 4,
                 53,
                 1001,
                 56,
                 -1,
                 56,
                 1005,
                 56,
                 6,
                 99,
                 0,
                 0,
                 0,
                 0,
                 10
               ])
    end
  end

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
