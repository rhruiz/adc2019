defmodule Amp do
  @moduledoc """
  Module to work with an amplifier
  """

  def run(amp, input) do
    input(amp, input)

    receive do
      {:output, ^amp, content} -> content
      {:halted, ^amp} -> :halt
    end
  end

  def start_link(program, phase, opts \\ []) do
    receiver = self()

    opts =
      Keyword.merge(
        [
          gets: fn _ ->
            receive do
              {:input, content} -> "#{content}\n"
            end
          end,
          puts: fn content ->
            send(receiver, {:output, self(), content})
          end
        ],
        opts
      )

    amp =
      spawn_link(fn ->
        Intcode.run(program, opts)
        send(receiver, {:halted, self()})
      end)

    input(amp, phase)

    amp
  end

  defp input(amp, input) do
    send(amp, {:input, input})
  end
end
