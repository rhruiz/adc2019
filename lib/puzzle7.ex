defmodule Puzzle7 do
  @moduledoc """
  AmpOps. Why does it have to be AmpOps?
  """

  import Puzzle5, only: [run_intcode: 1]
  import Puzzle2, only: [read_file: 1]
  import Mox

  def find_max_output(program \\ read_file("test/support/puzzle7/input.txt")) do
    0..4
    |> Enum.into([])
    |> permutations()
    |> Enum.map(fn seq -> {seq, test_phase_sequence(seq, program)} end)
    |> Enum.sort_by(&elem(&1, 1), &>=/2)
    |> hd()
    |> elem(1)
  end

  def permutations([]), do: [[]]

  def permutations(list),
    do: for(elem <- list, rest <- permutations(list -- [elem]), do: [elem | rest])

  def test_phase_sequence(seq, program) do
    Application.put_env(:adc2019, :io, IOMock)

    Enum.reduce(seq, 0, fn phase, input ->
      run_amp(program, phase, input)
    end)
  end

  def run_amp(program, phase, amp_input) do
    {:ok, grabber} = Agent.start_link(fn -> nil end)
    expect(IOMock, :gets, fn _ -> "#{phase}\n" end)
    expect(IOMock, :gets, fn _ -> "#{amp_input}\n" end)

    expect(IOMock, :puts, fn content ->
      Agent.update(grabber, fn _ -> content end)
      :ok
    end)

    run_intcode(program)

    Agent.get(grabber, fn content -> content end)
  end
end
