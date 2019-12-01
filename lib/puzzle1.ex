defmodule Puzzle1 do
  @moduledoc """
  First puzzle. Calculate fuel required for module masses.
  """

  @type mass :: non_neg_integer()

  @doc """
  Reads a file with one integer per line representing each module mass

  Crashes on invalid input
  """
  @spec from_input(Path.t()) :: mass()
  def from_input(path) do
    path
    |> File.stream!()
    |> Stream.map(&String.trim_trailing/1)
    |> Stream.map(&String.to_integer/1)
    |> total_fuel()
  end

  @doc """
  Receives a list of module masses and computes the total required fuel for
  those modules and the fuel required for those modules.
  """
  @spec total_fuel([mass()]) :: mass()
  def total_fuel(modules) do
    Enum.reduce(modules, 0, fn module, acc ->
      acc + fuel_for_module(module)
    end)
  end

  @doc """
  Computes the amount of fuel for a given module.
  Will iterate to compute fuel required for fuel.
  """
  @spec fuel_for_module(mass()) :: mass()
  def fuel_for_module(module) do
    module
    |> Stream.unfold(fn
      0 ->
        nil

      mass ->
        fuel = fuel(mass)
        {fuel, fuel}
    end)
    |> Enum.reduce(0, &Kernel.+/2)
  end

  @doc "Computes the amount of fuel for the given mass."
  @spec fuel(mass()) :: mass()
  def fuel(mass) do
    mass
    |> Kernel./(3)
    |> floor()
    |> Kernel.-(2)
    |> max(0)
  end
end
