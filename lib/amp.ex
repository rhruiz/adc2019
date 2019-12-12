defmodule Amp do
  @moduledoc """
  Module to work with an amplifier
  """

  def run(amp, input) do
    IntcodeRunner.input(amp, input)

    receive do
      {:output, ^amp, content} -> content
      {:halted, ^amp} -> :halt
    end
  end

  def start_link(program, phase, opts \\ []) do
    amp = IntcodeRunner.start_link(program, opts)
    IntcodeRunner.input(amp, phase)

    amp
  end
end
