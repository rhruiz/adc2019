defmodule Puzzle5Test do
  use ExUnit.Case, async: false

  import Mox
  import Puzzle5

  setup do
    Application.put_env(:adc2019, :io, IOMock)
  end

  setup :verify_on_exit!

  def expect_in_out(input, output) do
    expect(IOMock, :gets, fn "Input: " -> "#{input}\n" end)
    expect(IOMock, :puts, fn ^output -> :ok end)
  end

  describe "from_input/1" do
    test "runs the TESTs" do
      {:ok, prints} = Agent.start_link(fn -> [] end)

      expect(IOMock, :gets, fn "Input: " -> "1\n" end)

      stub(IOMock, :puts, fn content ->
        Agent.update(prints, fn contents ->
          [content | contents]
        end)
      end)

      from_input("test/support/puzzle5/input.txt")

      outputs = Agent.get(prints, fn contents -> contents end)

      assert [16_209_841 | tail] = outputs
      assert Enum.all?(tail, fn n -> n == 0 end)
    end

    test "runs the TESTs with conditionals" do
      expect_in_out(5, 8_834_787)

      from_input("test/support/puzzle5/input.txt")
    end
  end

  describe "run_intcode/1" do
    test "matches requirement 1" do
      assert 99 = [1002, 4, 3, 4, 33] |> run_intcode() |> List.last()
    end

    test "matches requirement 2" do
      assert 99 = [1101, 100, -1, 4, 0] |> run_intcode() |> Enum.at(4)
    end

    test "matches input/output requirement" do
      expect_in_out(42, 42)

      assert [42 | _] = [3, 0, 4, 0, 99] |> run_intcode()
    end

    test "matches equal to 8 condition in position mode" do
      expect_in_out(8, 1)
      expect_in_out(42, 0)

      [3, 9, 8, 9, 10, 9, 4, 9, 99, -1, 8] |> run_intcode()
      [3, 9, 8, 9, 10, 9, 4, 9, 99, -1, 8] |> run_intcode()
    end

    test "matches less than 8 condition in position mode" do
      expect_in_out(4, 1)
      expect_in_out(42, 0)

      [3, 9, 7, 9, 10, 9, 4, 9, 99, -1, 8] |> run_intcode()
      [3, 9, 7, 9, 10, 9, 4, 9, 99, -1, 8] |> run_intcode()
    end

    test "matches equal to 8 in immediate mode" do
      expect_in_out(8, 1)
      expect_in_out(42, 0)

      [3, 3, 1108, -1, 8, 3, 4, 3, 99] |> run_intcode()
      [3, 3, 1108, -1, 8, 3, 4, 3, 99] |> run_intcode()
    end

    test "matches less than 8 condition in immediate mode" do
      expect_in_out(4, 1)
      expect_in_out(42, 0)

      [3, 3, 1107, -1, 8, 3, 4, 3, 99] |> run_intcode()
      [3, 3, 1107, -1, 8, 3, 4, 3, 99] |> run_intcode()
    end

    test "matches jump test in position mode" do
      expect_in_out(42, 1)
      expect_in_out(0, 0)

      [3, 12, 6, 12, 15, 1, 13, 14, 13, 4, 13, 99, -1, 0, 1, 9] |> run_intcode()
      [3, 12, 6, 12, 15, 1, 13, 14, 13, 4, 13, 99, -1, 0, 1, 9] |> run_intcode()
    end

    test "matches jump test in immediate mode" do
      expect_in_out(42, 1)
      expect_in_out(0, 0)

      [3, 3, 1105, -1, 9, 1101, 0, 0, 12, 4, 12, 99, 1] |> run_intcode()
      [3, 3, 1105, -1, 9, 1101, 0, 0, 12, 4, 12, 99, 1] |> run_intcode()
    end

    test "matches the larger example" do
      run = fn ->
        run_intcode([
          3,
          21,
          1008,
          21,
          8,
          20,
          1005,
          20,
          22,
          107,
          8,
          21,
          20,
          1006,
          20,
          31,
          1106,
          0,
          36,
          98,
          0,
          0,
          1002,
          21,
          125,
          20,
          4,
          20,
          1105,
          1,
          46,
          104,
          999,
          1105,
          1,
          46,
          1101,
          1000,
          1,
          20,
          4,
          20,
          1105,
          1,
          46,
          98,
          99
        ])
      end

      expect_in_out(42, 1001)
      expect_in_out(0, 999)
      expect_in_out(8, 1000)

      run.()
      run.()
      run.()
    end
  end
end
