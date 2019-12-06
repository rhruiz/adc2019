defmodule Puzzle6 do
  @moduledoc """
  Compute orbits
  """

  @root "COM"

  def orbits do
    nodes = from_input("test/support/puzzle6/input.txt")

    nodes
    |> Map.keys()
    |> orbits(nodes, 0)
  end

  defp orbits([], _, acc) do
    acc
  end

  defp orbits([vertice | tail], node_map, acc) do
    acc = to_root(vertice, node_map, acc)
    orbits(tail, node_map, acc)
  end

  def to_root(@root, _, acc) do
    acc
  end

  def to_root(node, node_map, acc) do
    parent = Map.get(node_map, node)
    to_root(parent, node_map, acc + 1)
  end

  @spec from_input(Path.t()) :: term()
  def from_input(path) do
    path
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.map(&to_vertice/1)
    |> Enum.reduce(%{}, &insert_vertice/2)
  end

  def insert_vertice({parent, child}, map) do
    Map.put_new(map, child, parent)
  end

  def to_vertice(<<parent::binary-size(3), ")", child::binary-size(3)>>) do
    {parent, child}
  end
end
