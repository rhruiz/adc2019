defmodule Puzzle21Test do
  use ExUnit.Case, async: true

  test "avoids holes" do
    target = self()

    pid =
      "test/support/puzzle21/input.txt"
      |> Intcode.read_file()
      |> IntcodeRunner.start_link(puts: fn x -> send(target, {:output, self(), x}) end)

    assembly = 'OR A T\nAND B T\nAND C T\nNOT T J\nAND D J\nNOT J T\nWALK\n'

    Enum.each(assembly, fn xhr -> IntcodeRunner.input(pid, xhr) end)

    assert_receive {:halted, ^pid}
    assert_receive {:output, ^pid, 19_354_437}
  end
end
