defmodule Puzzle23.Node do
  @moduledoc """
  Encapsulate a host intcode/state
  """

  use GenServer

  @spec start_link(non_neg_integer(), Intcode.t()) :: GenServer.on_start()
  def start_link(host_id, program) do
    GenServer.start_link(__MODULE__, %{id: host_id, program: program})
  end

  def output(node) do
    GenServer.call(node, :output)
  end

  def packet(node, x, y) do
    GenServer.call(node, {:packet, x, y})
  end

  def state(node), do: GenServer.call(node, :state)

  def init(%{id: id, program: program}) do
    node = self()

    opts = [
      gets: fn _prompt ->
        receive do
          {:input, content} -> "#{content}\n"
        after
          0 ->
            send(node, :waiting_input)

            receive do
              {:input, content} -> "#{content}\n"
            end
        end
      end
    ]

    state = %{
      id: id,
      state: :started,
      output: :queue.new(),
      runner: IntcodeRunner.start_link(program, opts)
    }

    {:ok, state}
  end

  def handle_info(:waiting_input, %{state: :started} = state) do
    IntcodeRunner.input(state.runner, state.id)
    IntcodeRunner.input(state.runner, -1)

    {:noreply, %{state | state: :initialized}}
  end

  def handle_info(:waiting_input, state) do
    {:noreply,
     Map.update!(state, :state, fn
       :outputting -> :outputting
       _other -> :waiting_input
     end)}
  end

  def handle_info({:halted, runner}, %{runner: runner} = state) do
    {:noreply, %{state | state: :halted}}
  end

  def handle_info({:output, runner, content}, %{runner: runner} = state) do
    {:noreply, %{state | state: :outputting, output: :queue.in(content, state.output)}}
  end

  def handle_call(:state, _from, state) do
    reported_state = if(:queue.len(state.output) > 0, do: :outputting, else: :waiting_input)
    {:reply, reported_state, state}
  end

  def handle_call(:output, _from, state) do
    if :queue.len(state.output) > 2 do
      {{:value, target}, queue} = :queue.out(state.output)
      {{:value, x}, queue} = :queue.out(queue)
      {{:value, y}, queue} = :queue.out(queue)

      new_state = if(:queue.len(queue) > 0, do: :outputting, else: :waiting_input)

      {:reply, {target, x, y}, %{state | output: queue, state: new_state}}
    else
      {:reply, nil, state}
    end
  end

  def handle_call({:packet, x, y}, _from, state) do
    IntcodeRunner.input(state.runner, x)
    IntcodeRunner.input(state.runner, y)

    {:reply, :ok, %{state | state: :processing}}
  end
end
