defmodule Puzzle8Test do
  use ExUnit.Case, async: true

  import Puzzle8

  describe "render/0" do
    test "renders the image" do
      render() |> ansi()
    end
  end

  describe "render/3" do
    test "matches requirement 1" do
      assert [[0, 1], [1, 0]] =
               "0222112222120000"
               |> String.split("", trim: true)
               |> Enum.map(&String.to_integer/1)
               |> render(2, 2)
    end
  end

  describe "least_zeros/0" do
    test "matches requirement 1" do
      assert 2286 = least_zeros()
    end
  end

  describe "to_layers/3" do
    test "converts digits to layers and rows and cols" do
      assert [[[1, 2, 3], [4, 5, 6]], [[7, 8, 9], [0, 1, 2]]] =
               to_layers([1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 1, 2], 3, 2)
    end
  end
end
