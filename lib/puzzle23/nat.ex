defmodule Puzzle23.Nat do
  @moduledoc """
  NAT state server. Pings back when the same y has been received
  """

  use GenServer

  alias Puzzle23.Node

  def start_link(switch, host0) do
    GenServer.start_link(__MODULE__, [switch, host0])
  end

  def init([switch, host0]) do
    {:ok, %{host0: host0, switch: switch, pkt: nil, last: nil}}
  end

  def network_is_idle(nat) do
    GenServer.call(nat, :network_is_idle)
  end

  def packet(nat, x, y) do
    GenServer.call(nat, {:packet, {x, y}})
  end

  def handle_call({:packet, pkt}, _from, state) do
    {:reply, :ok, %{state | pkt: pkt}}
  end

  def handle_call(:network_is_idle, _from, %{pkt: nil} = state) do
    {:reply, :ok, state}
  end

  def handle_call(:network_is_idle, _from, %{pkt: pkt, last: pkt} = state) do
    {:reply, {:nat_response, pkt}, state}
  end

  def handle_call(:network_is_idle, _from, %{host0: host0, pkt: {x, y}} = state) do
    Node.packet(host0, x, y)
    {:reply, :ok, %{state | last: {x, y}}}
  end
end
