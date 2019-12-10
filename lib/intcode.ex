defmodule Intcode do
  @moduledoc """
  An intcode computer
  """

  alias Intcode.State

  @type t :: [integer()]
  @type input_mode :: 0 | 1 | 2
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
    9 => 1,
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
    |> String.trim()
    |> String.split(",", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  @doc """
  Runs the intcode program described by `input`
  """
  @spec run(t(), Keyword.t()) :: t()
  def run(input, opts \\ []) do
    run(input, %State{}, 0, opts)
  end

  defp run(input, state, address, opts) do
    {opcode, input_size, input_modes} =
      input
      |> Enum.at(address)
      |> parse_op()

    params =
      input
      |> Enum.slice(address + 1, input_size)
      |> Enum.zip(input_modes)

    apply(__MODULE__, :perform, [opcode, state, address, input, opts | params])
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

  defp read_input(_input, _state, {value, 1}), do: value

  defp read_input(input, _state, {position, 0}) do
    input
    |> pad(position + 1)
    |> Enum.at(position)
  end

  defp read_input(input, state = %{relative_base: base}, {relative, 2}) do
    read_input(input, state, {base + relative, 0})
  end

  defp write(input, %{relative_base: base}, _address, {position, 2}, value) do
    write(input, base + position, value)
  end

  defp write(_input, _state, _address, {_position, 1}, _value) do
    raise "boom"
  end

  defp write(input, _state, _address, {position, _}, value) do
    write(input, position, value)
  end

  defp write(_input, position, _value) when position < 0 do
    raise "boom"
  end

  defp write(input, position, value) do
    input
    |> pad(position + 1)
    |> List.replace_at(position, value)
  end

  def perform(99, _, _, input, _), do: input

  def perform(opcode, state, address, input, opts, a, b, position) when opcode in [1, 2, 7, 8] do
    a = read_input(input, state, a)
    b = read_input(input, state, b)

    input
    |> write(state, address, position, op(opcode).(a, b))
    |> run(state, address + 4, opts)
  end

  def perform(3, state, address, input, opts, position) do
    get_string = Keyword.get(opts, :gets, &io().gets/1)

    value =
      "Input: "
      |> get_string.()
      |> String.trim()
      |> String.to_integer()

    input
    |> write(state, address, position, value)
    |> run(state, address + 2, opts)
  end

  def perform(9, state, address, input, opts, target) do
    target = read_input(input, state, target)

    state = Map.update(state, :relative_base, 0, fn base -> base + target end)

    run(input, state, address + 2, opts)
  end

  def perform(4, state, address, input, opts, pos) do
    put_string = Keyword.get(opts, :puts, &io().puts/1)

    input |> read_input(state, pos) |> put_string.()

    run(input, state, address + 2, opts)
  end

  def perform(opcode, state, address, input, opts, conditional, target) when opcode in [5, 6] do
    input
    |> read_input(state, conditional)
    |> op(opcode).(0)
    |> jump(input, state, address, target, opts)
  end

  defp jump(true, input, state, _address, target, opts) do
    jump = read_input(input, state, target)
    run(input, state, jump, opts)
  end

  defp jump(false, input, state, address, _target, opts), do: run(input, state, address + 3, opts)

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
