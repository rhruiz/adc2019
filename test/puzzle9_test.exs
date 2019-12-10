defmodule Puzzle9Test do
  use ExUnit.Case, async: true

  import Mox

  setup :verify_on_exit!

  setup do
    Application.put_env(:adc2019, :io, IOMock)
  end

  test "performs BOOST tests" do
    {:ok, acc} = Agent.start_link(fn -> [] end)

    expect(IOMock, :gets, fn _ -> "1\n" end)

    stub(IOMock, :puts, fn output ->
      Agent.update(acc, fn acc -> [output | acc] end)
      :ok
    end)

    "test/support/puzzle9/input.txt"
    |> Intcode.read_file()
    |> Intcode.run()

    assert [3_380_552_333 | []] = Agent.get(acc, fn acc -> acc end)
  end
end
