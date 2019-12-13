defmodule IntcodeRunner do
  @moduledoc """
  Starts a process to run a code interactive intcode program
  """

  @type t :: pid()

  def input(runner, input) do
    send(runner, {:input, input})
  end

  @spec output(t()) :: :halted | term()
  def output(runner) do
    receive do
      {:output, ^runner, output} -> output
      {:halted, ^runner} -> :halted
    end
  end

  @spec start_link(Intcode.t(), Keyword.t()) :: t()
  def start_link(program, opts \\ []) do
    receiver = self()

    opts =
      Keyword.merge(
        [
          gets: fn prompt ->
            IO.inspect(prompt, label: "expecting input")

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
