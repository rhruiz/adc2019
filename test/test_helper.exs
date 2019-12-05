defmodule IOBehaviour do
  @callback gets(String.t()) :: String.t()
  @callback puts(String.t()) :: :ok
end

Mox.defmock(IOMock, for: IOBehaviour)
ExUnit.start()
