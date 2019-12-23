defmodule Puzzle16Test do
  use ExUnit.Case, async: true

  import Puzzle16

  describe "repeating_pattern/1" do
    test "star 1 requirement 1" do
      assert [0, 0, 1, 1, 1, 0, 0, 0, -1, -1, -1] =
               2
               |> repeating_pattern()
               |> Enum.take(11)
    end

    test "star 1 requirement 2" do
      assert [0, 1, 1, 0, 0, -1, -1, 0, 0, 1, 1, 0, 0, -1, -1] =
               1
               |> repeating_pattern()
               |> Enum.take(15)
    end
  end

  describe "fft/1" do
    test "star 1 requirement 1" do
      assert 48_226_158 =
               12_345_678
               |> Integer.digits()
               |> fft()
               |> Enum.into([])
               |> Integer.undigits()
    end

    test "star 1 requirement 2" do
      assert 34_040_438 =
               48_226_158
               |> Integer.digits()
               |> fft()
               |> Enum.into([])
               |> Integer.undigits()
    end

    test "star 1 requirement 3" do
      assert 3_415_518 =
               34_040_438
               |> Integer.digits()
               |> fft()
               |> Enum.into([])
               |> Integer.undigits()
    end

    test "star 1 requirement 4" do
      assert [0, 1, 0, 2, 9, 4, 9, 8] =
               [0, 3, 4, 1, 5, 5, 1, 8]
               |> fft()
               |> Enum.into([])
    end
  end

  describe "fft/2" do
    test "star 1 4 phases" do
      assert 1_029_498 ==
               12_345_678
               |> Integer.digits()
               |> fft(4)
               |> Integer.undigits()
    end

    test "star 1 requirement 1" do
      assert 24_176_176 =
               80_871_224_585_914_546_619_083_218_645_595
               |> Integer.digits()
               |> fft(100)
               |> Enum.take(8)
               |> Integer.undigits()
    end

    test "star 1 requirement 2" do
      assert 73_745_418 =
               19_617_804_207_202_209_144_916_044_189_917
               |> Integer.digits()
               |> fft(100)
               |> Enum.take(8)
               |> Integer.undigits()
    end

    test "star 1 requirement 3" do
      assert 52_432_133 =
               69_317_163_492_948_606_335_995_924_319_873
               |> Integer.digits()
               |> fft(100)
               |> Enum.take(8)
               |> Integer.undigits()
    end

    @tag timeout: :timer.minutes(2)
    test "from input" do
      assert 11_833_188 =
               "test/support/puzzle16/input.txt"
               |> File.read!()
               |> String.trim()
               |> String.split("", trim: true)
               |> Enum.map(&String.to_integer/1)
               |> fft(100)
               |> Enum.take(8)
               |> Integer.undigits()
    end
  end

  describe "message_offset/2" do
    @tag timeout: :timer.minutes(2)
    test "star 2 requirement 1" do
      assert 84_462_026 =
               "03036732577212944063491565474664"
               |> digits_repeated(10_000)
               |> message_offset()
               |> Integer.undigits()
    end

    @tag timeout: :timer.hours(2)
    test "with input file" do
      assert 55_005_000 =
               "test/support/puzzle16/input.txt"
               |> File.read!()
               |> String.trim()
               |> digits_repeated(10_000)
               |> message_offset()
               |> Integer.undigits()
    end
  end

  def digits_repeated(str, repeats) do
    str
    |> String.split("", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> List.duplicate(repeats)
    |> List.flatten()
  end
end
