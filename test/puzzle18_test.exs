defmodule Puzzle18Test do
  use ExUnit.Case, async: true

  import Puzzle18

  describe "shortest_path/2" do
    test "star 1 requirement 1" do
      assert 8 =
               "test/support/puzzle18/test_input.txt"
               |> read_file()
               |> (fn {map, keys} ->
                     shortest_path(map, keys)
                   end).()
    end

    test "star 1 requirement 2" do
      assert 86 =
               "test/support/puzzle18/test_input_2.txt"
               |> read_file()
               |> (fn {map, keys} ->
                     shortest_path(map, keys)
                   end).()
    end

    test "star 1 requirement 3" do
      assert 132 =
               "test/support/puzzle18/test_input_3.txt"
               |> read_file()
               |> (fn {map, keys} ->
                     shortest_path(map, keys)
                   end).()
    end

    test "star 1 requirement 4" do
      assert 136 =
               "test/support/puzzle18/test_input_4.txt"
               |> read_file()
               |> (fn {map, keys} ->
                     shortest_path(map, keys)
                   end).()
    end

    test "star 1 requirement 5" do
      assert 81 =
               "test/support/puzzle18/test_input_5.txt"
               |> read_file()
               |> (fn {map, keys} ->
                     shortest_path(map, keys)
                   end).()
    end

    test "star 1 from input" do
      assert 4544 =
               "test/support/puzzle18/input.txt"
               |> read_file()
               |> (fn {map, keys} ->
                     shortest_path(map, keys)
                   end).()
    end
  end
end
