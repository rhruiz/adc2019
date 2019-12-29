defmodule Puzzle23 do
  @moduledoc """
  Networking
  """

  alias Puzzle23.Nat
  alias Puzzle23.Node

  def boot_network(nhosts) do
    program = Intcode.read_file("test/support/puzzle23/input.txt")

    hosts =
      Enum.into(0..(nhosts - 1), %{}, fn id ->
        {:ok, pid} = Node.start_link(id, program)
        {id, pid}
      end)

    first_y_loop(hosts)
  end

  def first_y_loop(hosts) do
    Enum.find_value(hosts, fn {_id, host} ->
      case Node.output(host) do
        {255, x, y} ->
          {x, y}

        {target, x, y} ->
          Node.packet(hosts[target], x, y)
          nil

        _ ->
          nil
      end
    end)
    |> (fn
      {x, y} -> {x, y}
      _ -> first_y_loop(hosts)
    end).()
  end

  @spec boot_network(non_neg_integer()) :: {integer(), integer()}
  def boot_network(nhosts, nat) do
    program = Intcode.read_file("test/support/puzzle23/input.txt")
    switch = self()

    hosts =
      Enum.into(0..(nhosts - 1), %{}, fn id ->
        {:ok, pid} = Node.start_link(id, program)
        {id, pid}
      end)

    nat = nat.(switch, hosts[0])
    loop(hosts, nat)
  end

  def loop(hosts, nat) do
    Process.sleep(1)

    Enum.reduce(hosts, 0, fn
      {_id, host}, waiting_input ->
        case Node.output(host) do
          {255, x, y} ->
            Nat.packet(nat, x, y)
            waiting_input

          {target, x, y} ->
            Node.packet(hosts[target], x, y)
            waiting_input

          _ ->
            waiting_input + 1
        end
    end)
    |> (fn
      50 ->
        nat
        |> Nat.network_is_idle()
        |> (fn
          :ok -> loop(hosts, nat)
          {:nat_response, pkt} -> pkt
        end).()

      _ ->
        loop(hosts, nat)
    end).()
  end
end
