defmodule Puzzle23Test do
  use ExUnit.Case, async: true

  import Puzzle23

  describe "boot_network/1" do
    test "first y to 255" do
      assert {_x, 21_664} = boot_network(50)
    end
  end
end
