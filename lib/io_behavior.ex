defmodule IOBehaviour do
  @moduledoc """
  Behaviour to allow us to mock IO gets/puts functions
  """

  @callback gets(String.t()) :: String.t()
  @callback puts(String.t()) :: :ok
end
