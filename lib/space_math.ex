defmodule SpaceMath do
  @moduledoc """
  Math functions that are missing in the `:math` module
  """

  use Bitwise

  def lcm(a, b) do
    abs(Kernel.div(a * b, gcd(a, b)))
  end

  def gcd(a, 0), do: abs(a)

  def gcd(0, b), do: abs(b)
  def gcd(a, b) when a < 0 or b < 0, do: gcd(abs(a), abs(b))
  def gcd(a, b), do: gcd(b, rem(a, b))

  def extended_gcd(a, b) do
    {last_remainder, last_x} = extended_gcd(abs(a), abs(b), 1, 0, 0, 1)
    {last_remainder, last_x * if(a < 0, do: -1, else: 1)}
  end

  defp extended_gcd(last_remainder, 0, last_x, _, _, _), do: {last_remainder, last_x}

  defp extended_gcd(last_remainder, remainder, last_x, x, last_y, y) do
    quotient = div(last_remainder, remainder)
    remainder2 = rem(last_remainder, remainder)
    extended_gcd(remainder, remainder2, x, last_x - quotient * x, y, last_y - quotient * y)
  end

  def modpow(b, e, m), do: modpow(b, e, m, 1)

  def modpow(_, e, _, r) when e <= 0, do: r

  def modpow(b, e, m, r) do
    r =
      if Bitwise.band(e, 1) == 1 do
        rem(r * b, m)
      else
        r
      end

    modpow(rem(b * b, m), Bitwise.bsr(e, 1), m, r)
  end

  def inversemod(e, et) do
    {g, x} = extended_gcd(e, et)
    if g != 1, do: raise("The maths are broken!")
    rem(x + et, et)
  end
end
