defmodule Puzzle23.Nat do
  @moduledoc """
  NAT state server. Pings back when the same y has been received
  """

  use GenServer

  @timeout 100

  def start_link(switch, host0) do
    GenServer.start_link(__MODULE__, [switch, host0])
  end

  def init([switch, host0]) do
    {:ok, %{host0: host0, switch: switch, pkt: nil, tmp: nil, last: nil}}
  end

  def handle_info(:timeout, %{last: {x, y}, switch: switch, pkt: {x, y}} = state) do
    send(switch, {:nat_response, {x, y}})

    {:stop, :normal, state}
  end

  def handle_info(:timeout, %{tmp: tmp} = state) when tmp != nil do
    {:noreply, state, @timeout}
  end

  def handle_info(:timeout, %{pkt: {x, y}} = state) do
    IntcodeRunner.input(state.host0, x)
    IntcodeRunner.input(state.host0, y)

    {:noreply, %{state | last: {x, y}}, @timeout}
  end

  def handle_info({:input, value}, state) do
    {pkt, tmp} =
      case {state.pkt, state.tmp} do
        {curr, nil} ->
          {curr, value}

        {_curr, tmp} when tmp != nil ->
          {{tmp, value}, nil}
      end

    {:noreply, %{state | pkt: pkt, tmp: tmp}, @timeout}
  end
end
