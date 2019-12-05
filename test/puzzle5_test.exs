defmodule Puzzle5Test do
  use ExUnit.Case, async: false

  import ExUnit.CaptureIO
  import Puzzle5

  describe "from_input/1" do
    test "runs the TESTs" do
      output = capture_io fn ->
        from_input("test/support/puzzle5/input.txt")
      end

      assert output =~ "\n16209841\n"
    end
  end

  describe "run_intcode/1" do
    defmodule FakeIO do
      defdelegate puts(message), to: IO
      def gets("Input: "), do: "42\n"
    end

    test "matches requirement 1" do
      assert 99 = [1002, 4, 3, 4, 33] |> run_intcode() |> List.last()
    end

    test "matches requirement 2" do
      assert 99 = [1101, 100, -1, 4, 0] |> run_intcode() |> Enum.at(4)
    end

    test "matches input/output requirement" do
      output = capture_io fn ->
        Application.put_env(:adc2019, :io, FakeIO)
        assert [42 | _] = [3, 0, 4, 0, 99] |> run_intcode()
      end

      assert output =~ "42"
    end
  end
end
