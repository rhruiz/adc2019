defmodule Puzzle4 do
  @moduledoc """
  Computes possible passwords for the venus station
  """

  @type digits :: [non_neg_integer()]

  @range 402328..864247

  @spec possible_passwords() :: [integer()]
  def possible_passwords do
    @range
    |> Enum.filter(&is_valid_password?/1)
    |> length()
  end

  @spec is_valid_password?(integer()) :: boolean()
  def is_valid_password?(password) do
    tests = [
      :has_six_digits?,
      :digits_never_decrease?,
      :has_equal_adjacent_digits?
    ]

    digits = Integer.digits(password)

    Enum.all?(tests, fn test ->
      apply(__MODULE__, test, [digits])
    end)
  end

  @spec has_six_digits?(digits()) :: boolean()
  def has_six_digits?(digits), do: length(digits) == 6

  @spec digits_never_decrease?(digits()) :: boolean()
  def digits_never_decrease?(digits) do
    digits
    |> Enum.reduce({true, nil}, fn
      n, {_, nil} -> {true, n}
      m, {true, n} when m >= n -> {true, m}
      n, _ -> {false, n}
    end)
    |> elem(0)
  end

  @spec has_equal_adjacent_digits?(digits()) :: boolean()
  def has_equal_adjacent_digits?(digits) do
    digits
    |> Enum.chunk_by(fn digit -> digit end)
    |> Enum.any?(fn chunk -> length(chunk) == 2 end)
  end
end
