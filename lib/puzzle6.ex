defmodule Puzzle6 do
  @moduledoc """
  Compute orbits
  """

  @root "COM"
  @santa "SAN"
  @you "YOU"

  def from_you_to_san(file \\ "test/support/puzzle6/input.txt") do
    nodes = from_input(file)

    nodes_to_root = fn node ->
      node
      |> to_root(nodes, [])
      |> Enum.drop(-1)
    end

    nodes_to_root.(@you)
    |> nodes_between(nodes_to_root.(@santa))
    |> length()
    |> Kernel.-(1)
  end

  defp nodes_between([@root | you_tail], [@root | santa_tail]) do
    nodes_between(@root, you_tail, santa_tail)
  end

  defp nodes_between(_previous_head, [head | you_tail], [head | santa_tail]) do
    nodes_between(head, you_tail, santa_tail)
  end

  defp nodes_between(common, to_you, to_santa) do
    Enum.reverse(to_you) ++ [common] ++ to_santa
  end

  def orbits do
    nodes = from_input("test/support/puzzle6/input.txt")

    nodes
    |> Map.keys()
    |> orbits(nodes, 0)
  end

  defp orbits([], _, acc), do: acc

  defp orbits([vertice | tail], node_map, acc) do
    acc =
      vertice
      |> to_root(node_map, [])
      |> length()
      |> Kernel.-(1)
      |> Kernel.+(acc)

    orbits(tail, node_map, acc)
  end

  def to_root(@root, _, acc), do: [@root | acc]

  def to_root(node, node_map, acc) do
    parent = Map.get(node_map, node)
    to_root(parent, node_map, [node | acc])
  end

  defp from_input(path) do
    path
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.map(&to_vertice/1)
    |> Enum.reduce(%{}, &insert_vertice/2)
  end

  def insert_vertice({parent, child}, map) do
    Map.put_new(map, child, parent)
  end

  def to_vertice(line) do
    [parent, child] = String.split(line, ")")
    {parent, child}
  end
end
