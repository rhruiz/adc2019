defmodule Puzzle13Test do
  use ExUnit.Case, async: true

  import Puzzle13

  test "draws until halted" do
    assert 318 =
             [renderer: fn screen -> screen end]
             |> game(1)
             |> elem(0)
             |> blocks()
  end

  test "AI the shit out of this game" do
    receiver = fn state, and_then ->
      receive do
        {:input, target} ->
          send(target, {:input, 1})
          and_then.([1 | state], and_then)

        {:stop, target} ->
          send(target, {:state, self(), state})
          :ok
      end
    end

    guesser =
      spawn_link(fn ->
        receiver.([], receiver)
      end)

    game(
      gets: fn _ ->
        send(guesser, {:input, self()})

        receive do
          {:input, input} ->
            "#{input}\n"
        end
      end
    )
    |> elem(0)
    |> blocks()
    |> IO.inspect()

    send(guesser, {:stop, self()})

    receive do
      {:state, ^guesser, state} -> IO.inspect(state)
    end
  end

  test "games with quarters" do
    game(sleep: 50)
  end
end
