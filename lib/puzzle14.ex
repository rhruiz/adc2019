defmodule Puzzle14 do
  @moduledoc """
  Stoichiometry.
  """

  @type element :: String.t()
  @type quantity :: non_neg_integer()
  @type reagents :: [{quantity(), element()}]
  @type reaction :: {reagents, {quantity(), element()}}

  @fuel "FUEL"
  @ore "ORE"

  @spec from_file(Path.t()) :: %{element() => reaction()}
  def from_file(path) do
    path
    |> File.read!()
    |> reactions()
  end

  @spec reactions(String.t()) :: map()
  def reactions(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.trim/1)
    |> Enum.map(&parse_reaction/1)
    |> Enum.into(%{}, fn reaction = {_, {_, product}} ->
      {product, reaction}
    end)
  end

  @spec parse_reaction(String.t()) :: reaction()
  defp parse_reaction(line) do
    [reagents, product] = String.split(line, " => ", parts: 2, trim: true)

    product = quantity(product)

    reagents =
      reagents
      |> String.split(", ", trim: true)
      |> Enum.map(&quantity/1)

    {reagents, product}
  end

  defp quantity(line) do
    [q, element] = String.split(line, " ", trim: true)
    {String.to_integer(q), element}
  end

  def to_ore(reactions) do
    {reagents, {1, @fuel}} = reactions[@fuel]
    to_ore(reactions, reagents, 0, %{})
  end

  def to_ore(_reactions, [], ore, _buffer), do: ore

  def to_ore(reactions, [{needed, element} | tail], ore, buffer) when element == @ore do
    to_ore(reactions, tail, ore + needed, buffer)
  end

  def to_ore(reactions, [{needed, element} | tail], ore, buffer) do
    {reagents, {p, ^element}} = Map.get(reactions, element)
    existing = Map.get(buffer, element, 0)

    {needed, left} =
      case {needed, existing} do
        {a, b} when a >= b ->
          {needed - existing, 0}

        _ ->
          {0, existing - needed}
      end

    needed_reactions = ceil(needed / p)
    left = left + needed_reactions * p - needed
    buffer = Map.put(buffer, element, left)

    to_ore(reactions, tail ++ st(reagents, needed_reactions), ore, buffer)
  end

  def st(reagents, st) do
    Enum.map(reagents, fn {q, element} ->
      {q * st, element}
    end)
  end
end
