defmodule Puzzle5Test do
  use ExUnit.Case, async: false

  import Mox
  import Puzzle5

  setup do
    Application.put_env(:adc2019, :io, IOMock)
  end

  setup :verify_on_exit!

  describe "from_input/1" do
    test "runs the TESTs" do
      {:ok, prints} = Agent.start_link(fn -> [] end)

      expect(IOMock, :gets, fn "Input: " -> "1\n" end)

      stub(IOMock, :puts, fn content ->
        Agent.update(prints, fn contents ->
          [content | contents]
        end)
      end)

      from_input("test/support/puzzle5/input.txt")

      outputs = Agent.get(prints, fn contents -> contents end)

      assert [16_209_841 | tail] = outputs
      assert Enum.all?(tail, fn n -> n == 0 end)
    end

    test "runs the TESTs with conditionals" do
      expect(IOMock, :gets, fn "Input: " -> "#{5}\n" end)
      expect(IOMock, :puts, fn 8_834_787 -> :ok end)

      from_input("test/support/puzzle5/input.txt")
    end
  end
end
