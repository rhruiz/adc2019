defmodule Puzzle4Test do
  use ExUnit.Case, async: true

  import Puzzle4
  import Integer, only: [digits: 1]

  describe "possible_passwords/2" do
    test "returns the number of passwords in the range" do
      n = possible_passwords()
      assert n > 214
      assert n < 302

      assert 288 = n
    end
  end

  describe "is_valid_password?/1" do
    test "matches requirement 1" do
      assert is_valid_password?(112_233)
    end

    test "matches requirement 2" do
      refute is_valid_password?(223_450)
    end

    test "matches requirement 3" do
      refute is_valid_password?(123_789)
    end

    test "matches part 2 requirement 2" do
      refute is_valid_password?(123_444)
    end

    test "matches part 2 requirement 3" do
      assert is_valid_password?(111_122)
    end
  end

  describe "has_equal_adjacent_digits?/1" do
    test "returns true when there are equal adjacent digits" do
      assert has_equal_adjacent_digits?(digits(1337))
    end

    test "returns false when there are no equal adjacent digits" do
      refute has_equal_adjacent_digits?(digits(1373))
    end

    test "returns true when there are adjacent equal digits outside of a cluster" do
      assert has_equal_adjacent_digits?(digits(112_222))
      assert has_equal_adjacent_digits?(digits(222_211))
      assert has_equal_adjacent_digits?(digits(221_122))
      assert has_equal_adjacent_digits?(digits(221_333))
    end

    test "returns false when matching digits are part of a larger group" do
      refute has_equal_adjacent_digits?(digits(111_234))
    end
  end

  describe "digits_never_decrease?/1" do
    test "returns true when digits are increasing" do
      assert digits_never_decrease?(digits(1_234_567))
    end

    test "returns true if digits are the same" do
      assert digits_never_decrease?(digits(1337))
    end

    test "returns false if digits decrease" do
      refute digits_never_decrease?(digits(133_742))
    end
  end

  describe "has_six_digits?/1" do
    test "returns true with six digits" do
      assert has_six_digits?(digits(123_456))
    end

    test "returns false when has more than six" do
      refute has_six_digits?(digits(12_345_678))
    end

    test "returns false when has less than six" do
      refute has_six_digits?(digits(123))
    end
  end
end
