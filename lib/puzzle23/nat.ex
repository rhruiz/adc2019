defmodule Puzzle23.Nat do
  @moduledoc """
  NAT state server. Pings back when the same y has been received
  """

  use GenServer

  @timeout 400

  def start_link(switch, host0) do
    GenServer.start_link(__MODULE__, [switch, host0])
  end

  def init([switch, host0]) do
    {:ok, %{host0: host0, switch: switch, pkt: nil, tmp: nil, last: nil}, @timeout}
  end

  def handle_info({:input, -1}, state) do
    {:noreply, state, @timeout}
  end

  def handle_info(:timeout, %{pkt: nil} = state) do
    {:noreply, state, @timeout}
  end

  def handle_info(:timeout, %{last: {x, y}, switch: switch, pkt: {x, y}} = state) do
    send(switch, {:nat_response, {x, y}})

    {:stop, :normal, state}
  end

  def handle_info(:timeout, %{pkt: {x, y}} = state) do
    IntcodeRunner.input(state.host0, x)
    IntcodeRunner.input(state.host0, y)

    {:noreply, %{state | last: {x, y}}, @timeout}
  end

  def handle_info({:input, value}, state) do
    {pkt, tmp} =
      case {state.pkt, state.tmp} do
        {nil, nil} ->
          {nil, value}

        {nil, tmp} when tmp != nil ->
          {{tmp, value}, nil}

        {{x, y}, nil} ->
          {{x, y}, value}

        {_curr, tmp} when tmp != nil ->
          {{tmp, value}, nil}
      end

    {:noreply, %{state | pkt: pkt, tmp: tmp}, @timeout}
  end
end
