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
    amps =
      phases
      |> Enum.with_index()
      |> Enum.map(fn {phase, n} ->
        Amp.start_link(program, n, phase)
      end)

    last = length(amps) - 1
    receiver(0, 0, amps, last)
  end

  defp receiver(input, waiting_for, amps, last) do
    amps
    |> Enum.at(waiting_for)
    |> Amp.input(input)

    receive do
      {:output, ^waiting_for, output} ->
        next = rem(waiting_for + 1, last + 1)
        receiver(output, next, amps, last)

      {:halted, ^last} ->
        input
    end
  end

  defp run_amp(program, phase, amp_input) do
    ref = make_ref()

    amp = Amp.start_link(program, ref, phase)

    Amp.input(amp, amp_input)

    receive do
      {:output, ^ref, content} -> content
    end
  end
end
