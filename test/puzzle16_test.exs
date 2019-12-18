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
      assert 48226158 =
        12345678
        |> Integer.digits()
        |> fft()
        |> Enum.into([])
        |> Integer.undigits()
    end

    test "star 1 requirement 2" do
      assert 34040438 =
        48226158
        |> Integer.digits()
        |> fft()
        |> Enum.into([])
        |> Integer.undigits()
    end

    test "star 1 requirement 3" do
      assert 3415518 =
        34040438
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
      assert 1029498 ==
        12345678
        |> Integer.digits()
        |> fft(4)
        |> Integer.undigits()
    end

    test "star 1 requirement 1" do
      assert 24176176 =
        80871224585914546619083218645595
        |> Integer.digits()
        |> fft(100)
        |> Enum.take(8)
        |> Integer.undigits()
    end

    test "star 1 requirement 2" do
      assert 73745418 =
        19617804207202209144916044189917
        |> Integer.digits()
        |> fft(100)
        |> Enum.take(8)
        |> Integer.undigits()
    end

    test "star 1 requirement 3" do
      assert 52432133 =
        69317163492948606335995924319873
        |> Integer.digits()
        |> fft(100)
        |> Enum.take(8)
        |> Integer.undigits()
    end

    @tag timeout: :timer.minutes(2)
    test "from input" do
      assert 11833188 =
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
      assert 84462026 =
        "03036732577212944063491565474664"
        |> digits_repeated(10_000)
        |> message_offset()
        |> Integer.undigits()
    end

    @tag timeout: :timer.hours(2)
    test "with input file" do
      assert 55005000 =
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
