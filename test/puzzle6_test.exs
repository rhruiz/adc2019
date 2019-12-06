defmodule Puzzle6Test do
  use ExUnit.Case, async: true

  import Puzzle6

  describe "orbits/0" do
    test "counts direct and indirect orbits" do
      assert 223_251 = orbits()
    end
  end
end
