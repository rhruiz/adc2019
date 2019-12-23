defmodule Puzzle19Test do
  use ExUnit.Case, async: true

  import Puzzle19

  describe "scan/1" do
    assert 164 =
             "test/support/puzzle19/input.txt"
             |> Intcode.read_file()
             |> scan()
  end
end
