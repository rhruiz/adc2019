defmodule Vector do
  @moduledoc """
  Represents a tri dimensional vector
  """

  @type t :: %__MODULE__{x: number(), y: number(), z: number()}

  defstruct([:x, :y, :z])

  @spec new() :: t()
  def new, do: new(0, 0, 0)

  @spec new(number(), number(), number()) :: t()
  def new(x, y, z) do
    %__MODULE__{x: x, y: y, z: z}
  end

  @spec add(t(), t()) :: t()
  def add(%__MODULE__{x: x, y: y, z: z}, %__MODULE__{x: dx, y: dy, z: dz}) do
    new(x + dx, y + dy, z + dz)
  end
end
