defmodule IntcodeRunner do
  @moduledoc """
  Starts a process to run a code interactive intcode program
  """

  @type t :: pid()

  def input(runner, input) do
    send(runner, {:input, input})
  end

  def ascii_input(runner, str) do
    str
    |> to_charlist()
    |> Enum.reduce(runner, fn chr, runner ->
      input(runner, chr)

      receive do
        {:waiting_input, ^runner} ->
          runner
      end
    end)
    |> input(?\n)
  end

  def ascii_output(runner) do
    ascii_output(runner, [])
  end

  defp ascii_output(runner, buffer) do
    receive do
      {:output, ^runner, content} ->
        ascii_output(runner, [buffer | content])

      {:halted, ^runner} ->
        to_string(buffer)

      {:waiting_input, ^runner} ->
        to_string(buffer)
    end
  end

  @spec output(t()) :: :halted | term()
  def output(runner) do
    receive do
      {:output, ^runner, output} -> output
      {:halted, ^runner} -> :halted
    end
  end

  def start_link_ascii(program, opts \\ []) do
    receiver = self()

    opts =
      Keyword.merge(
        [
          gets: fn _prompt ->
            send(receiver, {:waiting_input, self()})

            receive do
              {:input, content} -> "#{content}\n"
            end
          end,
          puts: fn content -> send(receiver, {:output, self(), to_string([content])}) end
        ],
        opts
      )

    start_link(program, opts)
  end

  @spec start_link(Intcode.t(), Keyword.t()) :: t()
  def start_link(program, opts \\ []) do
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
