defmodule Puzzle23 do
  @moduledoc """
  Networking
  """

  def first_y(switch) do
    spawn_link(fn ->
      receive do
        {:input, x} when x != -1 ->
          receive do
            {:input, y} when y != -1 ->
              send(switch, {:nat_response, {x, y}})
          end
      end
    end)
  end

  @spec boot_network(non_neg_integer()) :: {integer(), integer()}
  def boot_network(nhosts, nat \\ &first_y/1) do
    program = Intcode.read_file("test/support/puzzle23/input.txt")
    switch = self()

    opts = [
      gets: fn _prompt ->
        receive do
          {:input, content} -> "#{content}\n"
        after
          0 -> "-1\n"
        end
      end
    ]

    hosts =
      Enum.into(0..(nhosts - 1), %{}, fn id ->
        pid = IntcodeRunner.start_link(program, opts)
        IntcodeRunner.input(pid, id)

        {id, pid}
      end)

    nat =
      case nat do
        nat when is_function(nat, 1) -> nat.(switch)
        nat when is_function(nat, 2) -> nat.(switch, hosts[0])
      end

    receiver(Map.put(hosts, 255, nat))
  end

  def receiver(hosts) do
    receive do
      {:nat_response, response} ->
        response

      {:output, host, target} ->
        receive do
          {:output, ^host, x} ->
            receive do
              {:output, ^host, y} ->
                IntcodeRunner.input(hosts[target], x)
                IntcodeRunner.input(hosts[target], y)
            end
        end

        receiver(hosts)
    end
  end
end
