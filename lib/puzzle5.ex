defmodule Puzzle5 do
  @moduledoc """
  TEST/intcode program for day 5
  """

  require Logger

  @type intcode :: [integer()]
  @type execution :: intcode()
  @type input_mode :: 0 | 1
  @type operation ::
          {opcode :: integer(), input_size :: non_neg_integer(), input_mode :: [input_mode()]}

  @input_size %{
    1 => 3,
    2 => 3,
    3 => 1,
    4 => 1,
    5 => 2,
    6 => 2,
    7 => 3,
    8 => 3,
    99 => 0
  }

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

  defp run_intcode(input, address) do
    {opcode, input_size, input_modes} =
      input
      |> Enum.at(address)
      |> parse_op()

    params =
      input
      |> Enum.slice(address + 1, input_size)
      |> Enum.zip(input_modes)

    apply(__MODULE__, :perform, [opcode, address, input | params])
  end

  @spec parse_op(integer()) :: operation()
  def parse_op(op) do
    case Enum.reverse(Integer.digits(op)) do
      [9, 9 | _] ->
        {99, 0, []}

      [opcode | []] ->
        input_size = @input_size[opcode]

        {opcode, input_size, pad([], input_size)}

      [opcode, _ | input_control] ->
        input_size = @input_size[opcode]

        {opcode, input_size, pad(input_control, input_size)}
    end
  end

  defp pad(collection, size, fill \\ 0)

  defp pad(collection, size, fill) when length(collection) < size do
    pad(collection ++ [fill], size, fill)
  end

  defp pad(collection, _, _) do
    collection
  end

  defp read_input(_input, {value, 1}), do: value

  defp read_input(input, {position, 0}) do
    Enum.at(input, position)
  end

  def perform(99, _, input), do: input

  def perform(opcode, address, input, a, b, {position, _}) when opcode in [1, 2, 7, 8] do
    a = read_input(input, a)
    b = read_input(input, b)

    input
    |> List.replace_at(position, op(opcode).(a, b))
    |> run_intcode(address + 4)
  end

  def perform(3, address, input, {position, _}) do
    value =
      "Input: "
      |> io().gets()
      |> String.trim()
      |> String.to_integer()

    input
    |> List.replace_at(position, value)
    |> run_intcode(address + 2)
  end

  def perform(4, address, input, pos) do
    input |> read_input(pos) |> io().puts()

    run_intcode(input, address + 2)
  end

  def perform(opcode, address, input, conditional, target) when opcode in [5, 6] do
    input
    |> read_input(conditional)
    |> op(opcode).(0)
    |> jump(input, address, target)
  end

  defp jump(true, input, _address, target) do
    jump = read_input(input, target)
    run_intcode(input, jump)
  end

  defp jump(false, input, address, _target), do: run_intcode(input, address + 3)

  defp io do
    Application.get_env(:adc2019, :io, IO)
  end

  defp op(1), do: &+/2
  defp op(2), do: &*/2
  defp op(5), do: &!=/2
  defp op(6), do: &==/2
  defp op(7), do: fn a, b -> if(a < b, do: 1, else: 0) end
  defp op(8), do: fn a, b -> if(a == b, do: 1, else: 0) end
end
