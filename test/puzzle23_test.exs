defmodule Puzzle23Test do
  use ExUnit.Case, async: true

  import Puzzle23

  describe "boot_network/1" do
    test "first y to 255" do
      assert {_x, 21_664} = boot_network(50)
    end

    test "first repeated y with wake up" do
      start_nat = fn switch, host0 ->
        {:ok, pid} = Puzzle23.Nat.start_link(switch, host0)
        pid
      end

      assert {_x, 16150} = boot_network(50, start_nat)
    end
  end
end
