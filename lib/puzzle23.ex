defmodule Puzzle23 do
  @moduledoc """
  Networking
  """

  def first_y(switch) do
    spawn_link fn ->
      receive do
        {:input, x} when x != -1 ->
          receive do
            {:input, y} when y != -1 ->
              send(switch, {:nat_response, {x, y}})
          end
      end
    end
  end

  @spec boot_network(non_neg_integer()) :: none()
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

    {hosts, buffer} =
      0..(nhosts - 1)
      |> Enum.reduce({%{}, %{}}, fn id, {hosts, buffer} ->
        pid = IntcodeRunner.start_link(program, opts)
        IntcodeRunner.input(pid, id)

        {
          Map.put(hosts, id, pid),
          Map.put(buffer, pid, :queue.new())
        }
      end)

    nat =
      case nat do
        nat when is_function(nat, 1) -> nat.(switch)
        nat when is_function(nat, 2) -> nat.(switch, hosts[0])
      end

    receiver(
      Map.put(hosts, 255, nat),
      Map.put(buffer, nat, :queue.new())
    )
  end

  def receiver(hosts, buffer) do
    receive do
      {:nat_response, response} ->
        response

      {:output, host, content} ->
        buffer =
          if :queue.len(buffer[host]) == 2 do
            {[target, x], y} = {:queue.to_list(buffer[host]), content}

            IntcodeRunner.input(hosts[target], x)
            IntcodeRunner.input(hosts[target], y)

            Map.put(buffer, host, :queue.new())
          else
            Map.update!(buffer, host, fn queue -> :queue.in(content, queue) end)
          end

        receiver(hosts, buffer)
    end
  end
end
