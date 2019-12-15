defmodule SpaceMath do
  @moduledoc """
  Math functions that are missing in the `:math` module
  """

  def lcm(a, b) do
    abs(Kernel.div(a * b, gcd(a, b)))
  end

  def gcd(a, 0), do: abs(a)

  def gcd(0, b), do: abs(b)
  def gcd(a, b) when a < 0 or b < 0, do: gcd(abs(a), abs(b))
  def gcd(a, b), do: gcd(b, rem(a, b))
end
