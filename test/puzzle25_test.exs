defmodule Puzzle25Test do
  use ExUnit.Case, async: true

  import Puzzle25

  describe "navigate/0" do
    test "finds the passcode" do
      assert navigate() =~ "typing 2147485856 on"
    end
  end
end
