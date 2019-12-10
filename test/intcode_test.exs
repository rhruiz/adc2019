defmodule IntcodeTest do
  use ExUnit.Case, async: true

  import Intcode
  import Mox

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

    test "crashes on bad input" do
      assert_raise ArgumentError, fn ->
        from_input("test/support/puzzle2/bad_input.txt")
      end
    end

    test "runs the program on input" do
      assert [30, 1, 1, 4, 2, 5, 6, 0, 99] == from_input("test/support/puzzle2/test_input.txt")
    end
  end

  describe "run/2" do
    test "runs the TESTs" do
      {:ok, prints} = Agent.start_link(fn -> [] end)

      expect(IOMock, :gets, fn "Input: " -> "1\n" end)

      stub(IOMock, :puts, fn content ->
        Agent.update(prints, fn contents ->
          [content | contents]
        end)
      end)

      "test/support/puzzle5/input.txt"
      |> read_file()
      |> run()

      outputs = Agent.get(prints, fn contents -> contents end)

      assert [16_209_841 | tail] = outputs
      assert Enum.all?(tail, fn n -> n == 0 end)
    end

    test "runs the TESTs with conditionals" do
      expect_in_out(5, 8_834_787)

      "test/support/puzzle5/input.txt"
      |> read_file()
      |> run()
    end

    test "matches requirement 1" do
      assert 99 = [1002, 4, 3, 4, 33] |> run() |> List.last()
    end

    test "matches requirement 2" do
      assert 99 = [1101, 100, -1, 4, 0] |> run() |> Enum.at(4)
    end

    test "matches input/output requirement" do
      expect_in_out(42, 42)

      assert [42 | _] = [3, 0, 4, 0, 99] |> run()
    end

    test "matches equal to 8 condition in position mode" do
      expect_in_out(8, 1)
      expect_in_out(42, 0)

      [3, 9, 8, 9, 10, 9, 4, 9, 99, -1, 8] |> run()
      [3, 9, 8, 9, 10, 9, 4, 9, 99, -1, 8] |> run()
    end

    test "matches less than 8 condition in position mode" do
      expect_in_out(4, 1)
      expect_in_out(42, 0)

      [3, 9, 7, 9, 10, 9, 4, 9, 99, -1, 8] |> run()
      [3, 9, 7, 9, 10, 9, 4, 9, 99, -1, 8] |> run()
    end

    test "matches equal to 8 in immediate mode" do
      expect_in_out(8, 1)
      expect_in_out(42, 0)

      [3, 3, 1108, -1, 8, 3, 4, 3, 99] |> run()
      [3, 3, 1108, -1, 8, 3, 4, 3, 99] |> run()
    end

    test "matches less than 8 condition in immediate mode" do
      expect_in_out(4, 1)
      expect_in_out(42, 0)

      [3, 3, 1107, -1, 8, 3, 4, 3, 99] |> run()
      [3, 3, 1107, -1, 8, 3, 4, 3, 99] |> run()
    end

    test "matches jump test in position mode" do
      expect_in_out(42, 1)
      expect_in_out(0, 0)

      [3, 12, 6, 12, 15, 1, 13, 14, 13, 4, 13, 99, -1, 0, 1, 9] |> run()
      [3, 12, 6, 12, 15, 1, 13, 14, 13, 4, 13, 99, -1, 0, 1, 9] |> run()
    end

    test "matches jump test in immediate mode" do
      expect_in_out(42, 1)
      expect_in_out(0, 0)

      [3, 3, 1105, -1, 9, 1101, 0, 0, 12, 4, 12, 99, 1] |> run()
      [3, 3, 1105, -1, 9, 1101, 0, 0, 12, 4, 12, 99, 1] |> run()
    end

    test "matches the larger example" do
      run = fn ->
        run([
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

    test "1,0,0,0,99 becomes 2,0,0,0,99 (1 + 1 = 2)" do
      assert [2, 0, 0, 0, 99] == run([1, 0, 0, 0, 99])
    end

    test "2,3,0,3,99 becomes 2,3,0,6,99 (3 * 2 = 6)" do
      assert [2, 3, 0, 6, 99] == run([2, 3, 0, 3, 99])
    end

    test "2,4,4,5,99,0 becomes 2,4,4,5,99,9801 (99 * 99 = 9801)" do
      assert [2, 4, 4, 5, 99, 9801] == run([2, 4, 4, 5, 99, 0])
    end

    test "1,1,1,4,99,5,6,0,99 becomes 30,1,1,4,2,5,6,0,99" do
      assert [30, 1, 1, 4, 2, 5, 6, 0, 99] == run([1, 1, 1, 4, 99, 5, 6, 0, 99])
    end
  end

  describe "opcode 9 and large number support" do
    test "writes at a large index" do
      program = [1001, 1, 0, 99, 99]
      resulting = run(program)

      assert ^program = Enum.slice(resulting, 0, 5)
      assert 1 = List.last(resulting)
      assert 100 = length(resulting)
      assert [0] =
        resulting
        |> Enum.slice(5, 94)
        |> Enum.uniq()
    end

    test "matches day 9 star 1 requirement 1" do
      {:ok, acc} = Agent.start_link(fn -> [] end)

      stub(IOMock, :puts, fn output ->
        Agent.update(acc, fn acc -> [output | acc] end)
        :ok
      end)

      program = [109, 1, 204, -1, 1001, 100, 1, 100, 1008, 100, 16, 101, 1006, 101, 0, 99]

      run(program)

      assert ^program =
               acc
               |> Agent.get(fn acc -> acc end)
               |> Enum.reverse()
    end

    test "matches day 9 star 1 requirement 2" do
      expect(IOMock, :puts, fn output ->
        assert 16 = output |> Integer.digits() |> length

        :ok
      end)

      run([1102, 34_915_192, 34_915_192, 7, 4, 7, 99, 0])
    end

    test "matches day 9 star 1 requirement 3" do
      expect(IOMock, :puts, fn 1_125_899_906_842_624 ->
        :ok
      end)

      run([104, 1_125_899_906_842_624, 99])
    end
  end
end
