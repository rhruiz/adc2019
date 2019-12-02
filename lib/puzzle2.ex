defmodule Puzzle2 do
  @moduledoc """
  This module implements the intcode program for puzzle day 2
  """

  @valid_ops [1, 2]

  @doc """
  Reads a file with the intcode program and runs it

  Crashes on invalid input
  """
  @spec from_input(Path.t()) :: [integer()]
  def from_input(path) do
    path
    |> File.read!()
    |> String.split(",")
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.to_integer/1)
    |> run_intcode()
  end

  @doc """
  Runs the intcode program described by `input`
  """
  @spec run_intcode([integer()]) :: [integer()]
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
        IO.inspect(other, label: "unexpected opcode")
        :halt_and_catch_fire
    end
  end

  defp op(1), do: &+/2
  defp op(2), do: &*/2
end
