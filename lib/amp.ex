defmodule Amp do
  @moduledoc """
  Module to work with an amplifier
  """

  import Puzzle5, only: [run_intcode: 2]

  def input(amp, input) do
    send(amp, {:input, input})
  end

  def start_link(program, ref, phase, opts \\ []) do
    receiver = self()

    opts = Keyword.merge([
      gets: fn _ ->
        receive do
          {:input, content} -> "#{content}\n"
        end
      end,
      puts: fn content ->
        send(receiver, {:output, ref, content})
      end
    ], opts)

    amp = spawn_link(fn ->
      run_intcode(program, opts)
      send(receiver, {:halted, ref})
    end)

    input(amp, phase)

    amp
  end
end
