defmodule Puzzle16 do
  @base_pattern [0, 1, 0, -1]

  @spec repeating_pattern(integer()) :: Stream.t()
  def repeating_pattern(index) do
    @base_pattern
    |> Stream.cycle()
    |> Stream.flat_map(fn element ->
      Stream.map(1..(index+1), fn _  -> element end)
    end)
    |> Stream.drop(1)
  end

  @spec fft([integer()], integer()) :: [integer()]
  def fft(input, phases) do
    Enum.reduce(1..phases, input, fn _phase, input ->
      fft(input)
    end)
  end

  @spec fft([integer()]) :: [integer()]
  def fft(input) do
    input
    |> Stream.with_index()
    |> Stream.map(fn {_digit, index} ->
      input
      |> Stream.zip(repeating_pattern(index))
      |> Enum.reduce(0, fn {n, pattern}, sum ->
        sum + n * pattern
      end)
      |> abs()
      |> rem(10)
    end)
    |> Enum.into([])
  end

  def do_phases(input, 0), do: input
  def do_phases(input, phases) do
    Enum.reduce(1..phases, input, fn _phase, input ->
      input
      |> Enum.reverse()
      |> Enum.reduce({0, []}, fn element, {sum, acc} ->
        sum = sum + element
        {sum, [rem(sum, 10) | acc]}
      end)
      |> elem(1)
    end)
  end

  @spec message_offset([integer()]) :: [integer()]
  def message_offset(input) do
    offset =
      input
      |> Enum.take(7)
      |> Integer.undigits()

    input
    |> do_phases(100)
    |> Enum.slice(offset, 8)
  end
end
