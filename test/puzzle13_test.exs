defmodule Puzzle13Test do
  use ExUnit.Case, async: true

  import Puzzle13

  test "draws until halted" do
    assert 318 =
             game(renderer: fn screen -> screen end)
             |> Enum.reduce(0, fn
               {_, "@"}, counter -> counter + 1
               _, counter -> counter
             end)
  end
end
