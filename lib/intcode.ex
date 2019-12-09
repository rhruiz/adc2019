defmodule Intcode do
  @moduledoc """
  An intcode computer
  """

  @type t :: [integer()]
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
  @spec from_input(Path.t()) :: Intcode.t()
  def from_input(path) do
    path
    |> read_file()
    |> run()
  end

  @doc """
  Loads the intcode in `path`
  """
  @spec read_file(Path.t()) :: Intcode.t()
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
  @spec run(t(), Keyword.t()) :: t()
  def run(input, opts \\ []) do
    run(input, 0, opts)
  end

  defp run(input, address, opts) do
    {opcode, input_size, input_modes} =
      input
      |> Enum.at(address)
      |> parse_op()

    params =
      input
      |> Enum.slice(address + 1, input_size)
      |> Enum.zip(input_modes)

    apply(__MODULE__, :perform, [opcode, address, input, opts | params])
  end

  @spec parse_op(integer()) :: operation()
  def parse_op(op) do
    {input_control, opcode} =
      op
      |> Integer.digits()
      |> Enum.split(-2)

    opcode = Integer.undigits(opcode)
    input_control = Enum.reverse(input_control)
    input_size = @input_size[opcode]

    {opcode, input_size, pad(input_control, input_size)}
  end

  defp pad(collection, size, fill \\ 0)

  defp pad(collection, size, fill) when length(collection) < size do
    pad(collection ++ [fill], size, fill)
  end

  defp pad(collection, _, _) do
    collection
  end

  defp read_input(_input, {value, 1}), do: value
  defp read_input(input, {position, 0}), do: Enum.at(input, position)

  defp write(input, position, value) do
    input
    |> pad(position)
    |> List.replace_at(position, value)
  end

  def perform(99, _, input, _), do: input

  def perform(opcode, address, input, opts, a, b, {position, _}) when opcode in [1, 2, 7, 8] do
    a = read_input(input, a)
    b = read_input(input, b)

    input
    |> write(position, op(opcode).(a, b))
    |> run(address + 4, opts)
  end

  def perform(3, address, input, opts, {position, _}) do
    get_string = Keyword.get(opts, :gets, &io().gets/1)

    value =
      "Input: "
      |> get_string.()
      |> String.trim()
      |> String.to_integer()

    input
    |> write(position, value)
    |> run(address + 2, opts)
  end

  def perform(4, address, input, opts, pos) do
    put_string = Keyword.get(opts, :puts, &io().puts/1)

    input |> read_input(pos) |> put_string.()

    run(input, address + 2, opts)
  end

  def perform(opcode, address, input, opts, conditional, target) when opcode in [5, 6] do
    input
    |> read_input(conditional)
    |> op(opcode).(0)
    |> jump(input, address, target, opts)
  end

  defp jump(true, input, _address, target, opts) do
    jump = read_input(input, target)
    run(input, jump, opts)
  end

  defp jump(false, input, address, _target, opts), do: run(input, address + 3, opts)

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
