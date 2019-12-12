defmodule Amp do
  @moduledoc """
  Module to work with an amplifier
  """

  @spec run(IntcodeRunner.t(), non_neg_integer()) :: :halt | term()
  def run(amp, input) do
    IntcodeRunner.input(amp, input)

    case IntcodeRunner.output(amp) do
      :halted -> :halt
      other -> other
    end
  end

  @spec start_link(Intcode.t(), non_neg_integer(), Keyword.t()) :: IntcodeRunner.t()
  def start_link(program, phase, opts \\ []) do
    amp = IntcodeRunner.start_link(program, opts)
    IntcodeRunner.input(amp, phase)

    amp
  end
end
