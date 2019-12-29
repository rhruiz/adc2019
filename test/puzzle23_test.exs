defmodule Puzzle23Test do
  use ExUnit.Case, async: false

  import Puzzle23

  describe "boot_network/1" do
    @tag timeout: :timer.seconds(5)
    test "first y to 255" do
      assert {_x, 21_664} = boot_network(50)
    end

    @tag timeout: :timer.seconds(5)
    test "first repeated y with wake up" do
      start_nat = fn switch, host0 ->
        {:ok, pid} = Puzzle23.Nat.start_link(switch, host0)
        pid
      end

      assert {_x, 16_150} = boot_network(50, start_nat)
    end
  end
end
