defmodule Puzzle12Test do
  use ExUnit.Case, async: true

  import Puzzle12

  @moons [:io, :europa, :ganymede, :callisto]

  describe "history repeats itself" do
    test "with input data" do
      positions =
        @moons
        |> Enum.zip(read_file())
        |> Enum.into(%{})

      velocities = stopped(@moons)

      assert 2772 =
        Stream.unfold({0, {positions, velocities}, MapSet.new()}, fn {counter, {p, v}, previous} ->
          if MapSet.member?(previous, {p, v}) do
            nil
          else
            {counter + 1, {counter + 1, step(@moons, p, v), MapSet.put(previous, {p, v})}}
          end
        end)
        |> Enum.reduce(fn counter, _ -> IO.inspect counter end)
    end

    test "with test data" do
      {positions, velocities} = Enum.reduce(step_through_test_input(), fn _, acc -> acc end)

      assert 2772 =
        Stream.unfold({0, {positions, velocities}, MapSet.new()}, fn {counter, {p, v}, previous} ->
          if MapSet.member?(previous, {p, v}) do
            nil
          else
            {counter + 1, {counter + 1, step(@moons, p, v), MapSet.put(previous, {p, v})}}
          end
        end)
        |> Enum.reduce(fn counter, _ -> counter end)
    end
  end

  test "total energy after 1000 steps" do
    positions =
      @moons
      |> Enum.zip(read_file())
      |> Enum.into(%{})

    {positions, velocities} =
      Enum.reduce(1..999, step(@moons, positions), fn _, {positions, velocities} ->
        step(@moons, positions, velocities)
      end)

    assert 13_399 =
             Enum.reduce(@moons, 0, fn moon, energy ->
               energy + energy(positions[moon], velocities[moon])
             end)
  end

  describe "step/3" do
    test "matches start 1 requirement 1" do
      Enum.reduce(step_through_test_input(), fn expected, {positions, velocities} ->
        assert ^expected = step(@moons, positions, velocities)
      end)
    end
  end

  describe "energy/2" do
    test "matches first star requirement 1" do
      {positions, velocities} = Enum.reduce(step_through_test_input(), fn a, _ -> a end)

      assert 179 =
               Enum.reduce(@moons, 0, fn moon, energy ->
                 energy + energy(positions[moon], velocities[moon])
               end)
    end
  end

  # pos=<x= 2, y=-1, z= 1>, vel=<x= 3, y=-1, z=-1>
  def parse_test_data(
        <<"pos=<x=", x::binary-size(2), ", y=", y::binary-size(3), ", z=", z::binary-size(2),
          ">, vel=<x=", vx::binary-size(2), ", y=", vy::binary-size(2), ", z=",
          vz::binary-size(2), ">">>
      ) do
    parse_test_data(x, y, z, vx, vy, vz)
  end

  def parse_test_data(
        <<"pos=<x=", x::binary-size(2), ", y=", y::binary-size(2), ", z=", z::binary-size(2),
          ">, vel=<x=", vx::binary-size(2), ", y=", vy::binary-size(2), ", z=",
          vz::binary-size(2), ">">>
      ) do
    parse_test_data(x, y, z, vx, vy, vz)
  end

  def parse_test_data(x, y, z, vx, vy, vz) do
    i = fn x -> x |> String.trim() |> String.to_integer() end

    {Vector.new(i.(x), i.(y), i.(z)), Vector.new(i.(vx), i.(vy), i.(vz))}
  end

  def step_through_test_input do
    "test/support/puzzle12/test_input_1.txt"
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.map(&parse_test_data/1)
    |> Stream.zip(Stream.cycle(@moons))
    |> Stream.map(fn {{p, v}, moon} -> {{moon, p}, {moon, v}} end)
    |> Stream.chunk_every(4)
    |> Stream.map(fn chunk ->
      Enum.reduce(chunk, {%{}, %{}}, fn {{moon, p}, {moon, v}}, {pacc, vacc} ->
        {Map.put(pacc, moon, p), Map.put(vacc, moon, v)}
      end)
    end)
  end
end
