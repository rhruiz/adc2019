defmodule Intcode.State do
  @moduledoc """
  Internal state for intcode execution
  """

  defstruct relative_base: 0

  def new(base \\ 0), do: %__MODULE__{relative_base: base}

  def rebase(state, value) do
    Map.update!(state, :relative_base, fn base -> base + value end)
  end
end
