defmodule Puzzle23 do
  @moduledoc """
  Networking
  """

  def first_y(switch) do
    fn ->
      nat = fn and_then ->
        send(switch, {:input_requested, self()})

        receive do
          {:input, -1} ->
            and_then.(and_then)

          {:input, x} ->
            receive do
              {:input, y} ->
                send(switch, {:nat_response, {x, y}})
            end
        end
      end

      nat.(nat)
    end
  end

  @spec boot_network(non_neg_integer()) :: none()
  def boot_network(nhosts, nat \\ &first_y/1) do
    program = Intcode.read_file("test/support/puzzle23/input.txt")
    switch = self()

    opts = [
      gets: fn _prompt ->
        send(switch, {:input_requested, self()})

        receive do
          {:input, content} -> "#{content}\n"
        end
      end
    ]

    {hosts, buffer, input_buffer} =
      0..(nhosts - 1)
      |> Enum.reduce({%{}, %{}, %{}}, fn id, {hosts, buffer, input_buffer} ->
        pid = IntcodeRunner.start_link(program, opts)

        receive do
          {:input_requested, ^pid} ->
            IntcodeRunner.input(pid, id)
        end

        {
          Map.put(hosts, pid, id),
          Map.put(buffer, pid, :queue.new()),
          Map.put(input_buffer, id, :queue.new())
        }
      end)

    receiver(Map.put(hosts, spawn_link(nat.(switch)), 255), buffer, input_buffer)
  end

  def receiver(hosts, buffer, input_buffer) do
    receive do
      {:nat_response, response} ->
        response

      {:output, host, content} ->
        {buffer, input_buffer} =
          if :queue.len(buffer[host]) == 2 do
            {[target, x], y} = {:queue.to_list(buffer[host]), content}

            {
              Map.put(buffer, host, :queue.new()),
              input_buffer
              |> Map.put_new_lazy(target, fn -> :queue.new() end)
              |> Map.update!(target, fn queue ->
                queue = :queue.in(x, queue)
                :queue.in(y, queue)
              end)
            }
          else
            {
              Map.update!(buffer, host, fn queue -> :queue.in(content, queue) end),
              input_buffer
            }
          end

        receiver(hosts, buffer, input_buffer)

      {:input_requested, host} ->
        id = hosts[host]
        queue = input_buffer[id]

        input_buffer =
          if queue != nil && :queue.len(queue) >= 2 do
            {to_send, rest} = :queue.split(2, queue)
            [x, y] = :queue.to_list(to_send)

            IntcodeRunner.input(host, x)
            IntcodeRunner.input(host, y)

            Map.put(input_buffer, id, rest)
          else
            IntcodeRunner.input(host, -1)
            input_buffer
          end

        receiver(hosts, buffer, input_buffer)
    end
  end
end
