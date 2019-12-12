defmodule Vector do
  defstruct x: 0, y: 0, z: 0

  def new(x, y, z) do
    %__MODULE__{x: x, y: y, z: z}
  end

  def new({x, y, z}), do: new(x, y, z)

  def add(%__MODULE__{x: x, y: y, z: z}, {dx, dy, dz}) do
    new(x + dx, y + dy, z + dz)
  end

  def add(%__MODULE__{x: x, y: y, z: z}, %__MODULE__{x: dx, y: dy, z: dz}) do
    new(x + dx, y + dy, z + dz)
  end

  def coordinates(%__MODULE__{x: x, y: y, z: z}), do: {x, y, z}
end
