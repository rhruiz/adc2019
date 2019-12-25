defmodule Puzzle22Test do
  use ExUnit.Case, async: true

  import Puzzle22
  import SpaceMath, only: [inversemod: 2]

  describe "compress/3" do
    test "from large repeated input" do
      length = 119_315_717_514_047
      iteractions = 101_741_582_076_661

      {a, b} =
        "test/support/puzzle22/input.txt"
        |> from_input()
        |> Enum.into([])
        |> compress(length, iteractions)

      assert 96_196_710_942_473 =
               Integer.mod(Integer.mod(2020 - b, length) * inversemod(a, length), length)
    end

    test "star 1 from input" do
      length = 10_007

      {a, b} =
        "test/support/puzzle22/input.txt"
        |> from_input()
        |> Enum.into([])
        |> compress(length, 1)

      assert 1538 = Integer.mod(a * 2019 + b, length)
    end
  end

  describe "deal_into_new_stack/1" do
    test "star 1 requirement 1" do
      assert [9, 8, 7, 6, 5, 4, 3, 2, 1, 0] = deal_into_new_stack([0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
    end
  end

  describe "cut/2" do
    test "star 1 requirement 1" do
      assert [3, 4, 5, 6, 7, 8, 9, 0, 1, 2] = cut([0, 1, 2, 3, 4, 5, 6, 7, 8, 9], 3)
    end

    test "star 1 requirement 2" do
      assert [6, 7, 8, 9, 0, 1, 2, 3, 4, 5] = cut([0, 1, 2, 3, 4, 5, 6, 7, 8, 9], -4)
    end
  end

  describe "deal_with_increment/2" do
    test "star 1 requirement 1" do
      assert [0, 7, 4, 1, 8, 5, 2, 9, 6, 3] =
               deal_with_increment([0, 1, 2, 3, 4, 5, 6, 7, 8, 9], 3)
    end
  end

  describe "parse_line/1" do
    test "parse cut" do
      assert [{Puzzle22, :cut, [42]}] = parse_line("cut 42")
      assert [{Puzzle22, :cut, [-42]}] = parse_line("cut -42")
    end

    test "parse deal_with_increment" do
      assert [{Puzzle22, :deal_with_increment, [37]}] = parse_line("deal with increment 37")
      assert [{Puzzle22, :deal_with_increment, [-37]}] = parse_line("deal with increment -37")
    end

    test "parse deal_into_new_stack" do
      assert [{Puzzle22, :deal_into_new_stack, []}] = parse_line("deal into new stack")
    end
  end

  describe "apply_shuffles/2" do
    test "star 1 requirement 1" do
      assert [0, 3, 6, 9, 2, 5, 8, 1, 4, 7] =
               [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
               |> deal_with_increment(7)
               |> deal_into_new_stack()
               |> deal_into_new_stack()
    end

    test "star 1 requirement 2" do
      assert [3, 0, 7, 4, 1, 8, 5, 2, 9, 6] =
               [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
               |> cut(6)
               |> deal_with_increment(7)
               |> deal_into_new_stack()
    end

    test "star 1 requirement 3" do
      assert [6, 3, 0, 7, 4, 1, 8, 5, 2, 9] =
               [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
               |> deal_with_increment(7)
               |> deal_with_increment(9)
               |> cut(-2)
    end

    test "star 1 requirement 4" do
      assert [9, 2, 5, 8, 1, 4, 7, 0, 3, 6] =
               [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
               |> deal_into_new_stack()
               |> cut(-2)
               |> deal_with_increment(7)
               |> cut(8)
               |> cut(-4)
               |> deal_with_increment(7)
               |> cut(3)
               |> deal_with_increment(9)
               |> deal_with_increment(3)
               |> cut(-1)
    end
  end
end
