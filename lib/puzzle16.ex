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
    Enum.reduce(1..phases, input, fn phase, input ->
      IO.inspect(phase, label: "phase")
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
      |> Integer.digits()
      |> List.last()
      |> abs()
    end)
    |> Enum.take(length(input))
  end

  @spec message_offset([integer()]) :: [integer()]
  def message_offset(input) do
    offset =
      input
      |> Enum.take(7)
      |> Integer.undigits()

    input
    |> fft(100)
    |> IO.inspect()
    |> Enum.slice(offset, 8)
  end
end
