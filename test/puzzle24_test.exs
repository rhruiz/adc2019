defmodule Puzzle24Test do
  use ExUnit.Case, async: true

  import ExUnit.CaptureIO, only: [capture_io: 1]
  import Puzzle24

  describe "render/1" do
    test "with test input" do
      content = File.read!("test/support/puzzle24/test_input_1.txt")

      assert ^content =
               capture_io(fn ->
                 content
                 |> read_string()
                 |> render()
               end)
    end

    test "with input" do
      content = File.read!("test/support/puzzle24/input.txt")

      assert ^content =
               capture_io(fn ->
                 content
                 |> read_string()
                 |> render()
               end)
    end
  end

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

  describe "move/2" do
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
               |> move(1)
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
               |> move(2)
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
               |> move(3)
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
               |> move(4)
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
