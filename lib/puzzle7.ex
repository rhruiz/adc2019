defmodule Puzzle7 do
  @moduledoc """
  AmpOps. Why does it have to be AmpOps?
  """

  import Puzzle5, only: [run_intcode: 1]
  import Puzzle2, only: [read_file: 1]
  import Mox

  def find_max_output(program \\ read_file("test/support/puzzle7/input.txt")) do
    test_phases(0..4, program, &test_phase_sequence/2)
  end

  def find_max_output_with_feedback_loop(program \\ read_file("test/support/puzzle7/input.txt")) do
    test_phases(5..9, program, &run_feedback_loop/2)
  end

  def test_phase_sequence(seq, program) do
    Application.put_env(:adc2019, :io, IOMock)

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
    Application.put_env(:adc2019, :io, IOMock)

    amps =
      phases
      |> Enum.with_index()
      |> Enum.map(fn {phase, n} ->
        start_amp(program, n, phase)
      end)

    last = length(amps) - 1
    receiver(0, 0, amps, last)
  end

  defp receiver(input, waiting_for, amps, last) do
    amps
    |> Enum.at(waiting_for)
    |> send({:input, input})

    receive do
      {:output, ^waiting_for, output} ->
        next = rem(waiting_for + 1, last + 1)
        receiver(output, next, amps, last)

      {:halted, ^last} ->
        input
    end
  end

  defp start_amp(program, ref, phase) do
    receiver = self()

    amp =
      spawn_link(fn ->
        stub(IOMock, :gets, fn _ ->
          receive do
            {:input, content} -> "#{content}\n"
          end
        end)

        stub(IOMock, :puts, fn content ->
          send(receiver, {:output, ref, content})
        end)

        run_intcode(program)
        send(receiver, {:halted, ref})
      end)

    send(amp, {:input, phase})

    amp
  end

  defp run_amp(program, phase, amp_input) do
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
