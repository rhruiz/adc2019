defmodule Puzzle24Test do
  use ExUnit.Case, async: true

  import Puzzle24

  describe "biodiversity/1" do
    test "star 1 requirement 1" do
      assert 2_129_920 =
               """
               .....
               .....
               .....
               #....
               .#...
               """
               |> read_string()
               |> biodiversity()
    end
  end

  describe "simulate/2" do
    test "star 1 requirement 1" do
      expected =
        """
        #..#.
        ####.
        ###.#
        ##.##
        .##..
        """
        |> read_string()

      assert expected ==
               "test/support/puzzle24/test_input_1.txt"
               |> read_file()
               |> simulate(1)
    end

    test "star 1 requirement 2" do
      expected =
        """
        #####
        ....#
        ....#
        ...#.
        #.###
        """
        |> read_string()

      assert expected ==
               "test/support/puzzle24/test_input_1.txt"
               |> read_file()
               |> simulate(2)
    end

    test "star 1 requirement 3" do
      expected =
        """
        #....
        ####.
        ...##
        #.##.
        .##.#
        """
        |> read_string()

      assert expected ==
               "test/support/puzzle24/test_input_1.txt"
               |> read_file()
               |> simulate(3)
    end

    test "star 1 requirement 4" do
      expected =
        """
        ####.
        ....#
        ##..#
        .....
        ##...
        """
        |> read_string()

      assert expected ==
               "test/support/puzzle24/test_input_1.txt"
               |> read_file()
               |> simulate(4)
    end
  end

  test "finds first repeated layout with test input" do
    game = read_file("test/support/puzzle24/test_input_1.txt")

    assert 2_129_920 =
             {game, MapSet.new()}
             |> Stream.unfold(fn
               true ->
                 nil

               {game, seen} ->
                 b = biodiversity(game)

                 if b in seen do
                   {[game], true}
                 else
                   {[], {move(game), MapSet.put(seen, b)}}
                 end
             end)
             |> Stream.flat_map(fn x -> x end)
             |> Enum.take(1)
             |> hd()
             |> biodiversity()
  end

  test "finds first repeated layout with input" do
    game = read_file("test/support/puzzle24/input.txt")

    assert 17_863_711 =
             {game, MapSet.new()}
             |> Stream.unfold(fn
               true ->
                 nil

               {game, seen} ->
                 b = biodiversity(game)

                 if b in seen do
                   {[game], true}
                 else
                   {[], {move(game), MapSet.put(seen, b)}}
                 end
             end)
             |> Stream.flat_map(fn x -> x end)
             |> Enum.take(1)
             |> hd()
             |> biodiversity()
  end
end
