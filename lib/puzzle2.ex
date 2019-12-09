defmodule Puzzle2 do
  @moduledoc """
  This module implements the intcode program for puzzle day 2
  """

  require Logger

  @doc """
  Iterates over the first two inputs of the opcode to find which combination yeilds the given
  output
  """
  @spec find_output(integer()) :: {integer(), integer()} | :not_found
  def find_output(output \\ 19_690_720) do
    "test/support/puzzle2/input.txt"
    |> Intcode.read_file()
    |> find_output(output, 0)
  end

  defp find_output(_, _, 10_000) do
    :not_found
  end

  defp find_output(input, output, n) do
    {a, b} = {div(n, 100), rem(n, 100)}

    case test_input(input, a, b) do
      [^output | _] -> {a, b}
      _ -> find_output(input, output, n + 1)
    end
  end

  @doc """
  Runs the intcode in `input` replacing the inputs at position 1 and 2 with a and b
  """
  @spec test_input(Intcode.t(), integer(), integer()) :: Intcode.t()
  def test_input([head, _, _ | tail], a, b) do
    Intcode.run([head, a, b | tail])
  end
end
