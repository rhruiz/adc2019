defmodule Puzzle22Test do
  use ExUnit.Case, async: true

  import Puzzle22

  describe "reverse/2" do
    test "undos a cut" do
      original = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
      at = 3
      transformed = cut(original, at)
      length = length(original)

      transformed
      |> Enum.with_index()
      |> Enum.each(fn {element, index} ->
        original_index = reverse(:cut, [length, index, at])

        assert Enum.at(original, original_index) == element
      end)
    end

    test "undos a deal with increment" do
      original = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
      increment = 3
      transformed = deal_with_increment(original, increment)
      length = length(original)

      transformed
      |> Enum.with_index()
      |> Enum.each(fn {element, index} ->
        original_index = reverse(:deal_with_increment, [length, index, increment])
                         |>IO.inspect

        assert Enum.at(original, original_index) == element
      end)
    end

    test "undos a deal into new stack" do
      original = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
      transformed = deal_into_new_stack(original)
      length = length(original)

      transformed
      |> Enum.with_index()
      |> Enum.each(fn {element, index} ->
        original_index = reverse(:deal_into_new_stack, [length, index])

        assert Enum.at(original, original_index) == element
      end)
    end

    test "finds card 2020 on large input" do
      length = 119315717514047
      times = 1..101741582076661

      transformations =
        from_input("test/support/puzzle22/input.txt")
        |> Stream.map(fn {mod, fun, args} ->
          fn index ->
            apply(mod, :reverse, [fun, [length, index | args]])
          end
        end)
        |> Enum.reverse()

      times
      |> Stream.flat_map(fn _n -> transformations end)
      |> Enum.reduce({0, 2020}, fn transformation, {counter, index} ->

        if rem(counter, 10_000_000) == 0 do
          IO.puts "#{counter}"
          IO.puts "10174158207666100"
        end

        {counter + 1, transformation.(index)}
      end)
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

    test "star 1 from input" do
      shuffles = from_input("test/support/puzzle22/input.txt")

      assert 1538 =
               0..10_006
               |> apply_shuffles(shuffles)
               |> Enum.find_index(fn card -> card == 2019 end)
    end
  end
end
