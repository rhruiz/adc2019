defmodule Puzzle6Test do
  use ExUnit.Case, async: true

  import Puzzle6

  describe "orbits/0" do
    test "counts direct and indirect orbits" do
      assert 223_251 = orbits()
    end
  end

  describe "from_you_to_san/1" do
    test "returns the mininal path" do
      assert 430 = from_you_to_san()
    end

    test "returns 4 from test orbits" do
      assert 4 = from_you_to_san("test/support/puzzle6/test_input.txt")
    end
  end
end
