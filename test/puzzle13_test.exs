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

  @tag timeout: :infinity
  test "enable game genie. and wall hacks. and auto aim" do
    next_move = fn
      a, a -> 0
      a, b when a > b -> 1
      _, _ -> -1
    end

    {:ok, buffer} = Agent.start_link(fn -> [] end)
    {:ok, score} = Agent.start_link(fn -> 0 end)
    ball = 4
    paddle = 3
    game = load_game()

    game_state = fn ->
      state =
        buffer
        |> Agent.get(&Enum.reverse/1)
        |> Enum.chunk_every(3)
        |> Enum.reduce(%{score: 0, ball: 0, paddle: 0}, fn
          [x, _, ^ball], state -> %{state | ball: x}
          [x, _, ^paddle], state -> %{state | paddle: x}
          [-1, _, score], state -> %{state | score: score}
          _, state -> state
        end)

      Agent.update(score, fn score -> max(score, state.score) end)

      state
    end

    opts = [
      puts: fn output ->
        Agent.update(buffer, fn content -> [output | content] end)
        :ok
      end,
      gets: fn _ ->
        state = game_state.()
        Agent.update(buffer, fn _ -> [] end)
        move = next_move.(state.ball, state.paddle)

        "#{move}\n"
      end
    ]

    Intcode.run(game, opts)
    game_state.()

    assert 16_309 = Agent.get(score, fn score -> score end)
  end
end
