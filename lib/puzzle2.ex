defmodule Puzzle2 do
  @moduledoc """
  This module implements the intcode program for puzzle day 2
  """

  require Logger

  @type intcode :: [integer()]
  @type execution :: intcode | :halt_and_catch_fire

  @valid_ops [1, 2]

  @doc """
  Reads a file with the intcode program and runs it

  Crashes on invalid input
  """
  @spec from_input(Path.t()) :: intcode()
  def from_input(path) do
    path
    |> read_file()
    |> run_intcode()
  end

  @doc """
  Iterates over the first two inputs of the opcode to find which combination yeilds the given
  output
  """
  @spec find_output(integer()) :: {integer(), integer()} | :not_found
  def find_output(output \\ 19690720) do
    input = read_file("test/support/puzzle2/input.txt")

    0..99
    |> Stream.flat_map(fn a -> Enum.map(0..99, fn b -> {a, b} end) end)
    |> Enum.find(:not_found, fn {a, b} ->
      case test_input(input, a, b) do
        [^output | _] -> true
        _ -> false
      end
    end)
  end

  @doc """
  Runs the intcode in `input` replacing the inputs at position 1 and 2 with a and b
  """
  @spec test_input(intcode(), integer(), integer()) :: execution()
  def test_input(input, a, b) do
    input
    |> List.replace_at(1, a)
    |> List.replace_at(2, b)
    |> run_intcode()
  end

  @doc """
  Loads the intcode in `path`
  """
  @spec read_file(Path.t()) :: intcode()
  def read_file(path) do
    path
    |> File.read!()
    |> String.split(",")
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.to_integer/1)
  end

  @doc """
  Runs the intcode program described by `input`
  """
  @spec run_intcode(intcode()) :: execution()
  def run_intcode(input) do
    run_intcode(input, 0)
  end

  defp run_intcode(input, index) do
    case Enum.at(input, index) do
      99 ->
        input

      op when op in @valid_ops ->
        [op, a, b, target] = Enum.slice(input, index, 4)
        a = Enum.at(input, a)
        b = Enum.at(input, b)

        input
        |> List.replace_at(target, op(op).(a, b))
        |> run_intcode(index + 4)

      other ->
        Logger.error("unexpected opcode: #{other}")
        :halt_and_catch_fire
    end
  end

  defp op(1), do: &+/2
  defp op(2), do: &*/2
end
