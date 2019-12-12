defmodule IntcodeRunner do
  @moduledoc """
  Starts a process to run a code interactive intcode program
  """

  def input(amp, input) do
    send(amp, {:input, input})
  end

  @spec start_link(Intcode.t(), Keyword.t()) :: pid()
  def start_link(program, opts) do
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

    spawn_link(fn ->
      Intcode.run(program, opts)
      send(receiver, {:halted, self()})
    end)
  end
end
