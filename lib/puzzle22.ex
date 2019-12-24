defmodule Puzzle22 do
  @moduledoc """
  Card tricks
  """

  def reverse(:cut, [length, index, at]) do
    rem(index + at, length)
  end

  def reverse(:deal_with_increment, [_length, 0, _increment]) do
    0
  end

  def reverse(:deal_with_increment, [length, index, increment]) do
    length - rem(increment * index, length)
  end

  def reverse(:deal_into_new_stack, [length, index]) do
    length - 1 - index
  end

  def deal_into_new_stack(cards), do: Enum.reverse(cards)

  def cut(cards, at) do
    {left, right} = Enum.split(cards, at)
    right ++ left
  end

  def deal_with_increment(cards, increment) do
    total = length(cards)
    target = 0 |> Range.new(total - 1) |> Enum.to_list()

    cards
    |> Enum.with_index()
    |> Enum.reduce(target, fn {card, idx}, target ->
      List.replace_at(target, rem(idx * increment, total), card)
    end)
  end

  def from_input(path) do
    path
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.flat_map(&parse_line/1)
  end

  def apply_shuffles(cards, shuffles) do
    Enum.reduce(shuffles, cards, fn {m, f, a}, cards ->
      apply(m, f, [cards | a])
    end)
  end

  def parse_line(line) do
    ~r/^(?<fun>[^0-9\-]+)(?: (?<arg>\-?\d+))?$/
    |> Regex.named_captures(line)
    |> (fn
          nil ->
            []

          %{"fun" => fun, "arg" => ""} ->
            [{__MODULE__, to_fun(fun), []}]

          %{"fun" => fun, "arg" => arg} ->
            [{__MODULE__, to_fun(fun), [String.to_integer(arg)]}]
        end).()
  end

  defp to_fun(name) do
    name
    |> String.replace(" ", "_")
    |> String.to_atom()
  end
end
