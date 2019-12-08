defmodule Puzzle7 do
  @moduledoc """
  AmpOps. Why does it have to be AmpOps?
  """

  import Puzzle2, only: [read_file: 1]

  def find_max_output(program \\ read_file("test/support/puzzle7/input.txt")) do
    test_phases(0..4, program, &test_phase_sequence/2)
  end

  def find_max_output_with_feedback_loop(program \\ read_file("test/support/puzzle7/input.txt")) do
    test_phases(5..9, program, &run_feedback_loop/2)
  end

  def test_phase_sequence(seq, program) do
    Enum.reduce(seq, 0, fn phase, input ->
      run_amp(program, phase, input)
    end)
  end

  defp permutations([]), do: [[]]

  defp permutations(list),
    do: for(elem <- list, rest <- permutations(list -- [elem]), do: [elem | rest])

  defp test_phases(phases, program, runner) do
    phases
    |> Enum.into([])
    |> permutations()
    |> Enum.map(fn seq -> {seq, runner.(seq, program)} end)
    |> Enum.sort_by(&elem(&1, 1), &>=/2)
    |> hd()
    |> elem(1)
  end

  def run_feedback_loop(phases, program) do
    phases
    |> Enum.map(fn phase -> Amp.start_link(program, phase) end)
    |> (fn amps ->
      [amps, Stream.cycle(0..4), Stream.cycle([length(phases) - 1])]
    end).()
    |> List.wrap()
    |> Stream.zip()
    |> Stream.cycle()
    |> Stream.transform(0, fn {amp, index, last}, input ->
      case {index, last, Amp.run(amp, input)} do
        {n, n, :halt} ->
          {[input], :halt}

        {_, _, :halt} ->
          {[], input}

        {_, _, output} ->
          {[], output}
      end
    end)
    |> Enum.take(1)
    |> hd()
  end

  defp run_amp(program, phase, amp_input) do
    program
    |> Amp.start_link(phase)
    |> Amp.run(amp_input)
  end
end
