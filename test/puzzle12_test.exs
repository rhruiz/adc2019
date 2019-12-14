defmodule Puzzle12Test do
  use ExUnit.Case, async: true

  import Puzzle12
  import SpaceMath

  @moons [:io, :europa, :ganymede, :callisto]

  describe "history repeats itself" do
    test "with input data" do
      positions =
        @moons
        |> Enum.zip(read_file())
        |> Enum.into(%{})

      velocities = stopped(@moons)

      positions_and_velocities =
        1..300_000
        |> Enum.reduce([{positions, velocities}], fn _step, [{p, v} | _] = acc ->
          [step(@moons, p, v) | acc]
        end)
        |> Enum.reverse()

      x = find_repetition(positions_and_velocities, :x)
      y = find_repetition(positions_and_velocities, :y)
      z = find_repetition(positions_and_velocities, :z)

      assert 312_992_287_193_064 == lcm(x, lcm(y, z))
    end

    test "long running example" do
      data = """
      <x=-8, y=-10, z= 0>
      <x= 5, y= 5, z=10>
      <x= 2, y=-7, z= 3>
      <x= 9, y=-8, z=-3>
      """

      positions =
        data
        |> String.split("\n", trim: true)
        |> Enum.map(&parse_test_data/1)
        |> Enum.zip(@moons)
        |> Enum.into(%{}, fn {v, k} -> {k, v} end)

      velocities = stopped(@moons)

      positions_and_velocities =
        1..50_000
        |> Enum.reduce([{positions, velocities}], fn _step, [{p, v} | _] = acc ->
          [step(@moons, p, v) | acc]
        end)
        |> Enum.reverse()

      x = find_repetition(positions_and_velocities, :x)
      y = find_repetition(positions_and_velocities, :y)
      z = find_repetition(positions_and_velocities, :z)

      assert 4_686_774_924 == lcm(x, lcm(y, z))
    end

    test "with test data" do
      {positions, velocities} = Enum.reduce(step_through_test_input(), fn _, acc -> acc end)

      assert 2772 =
               Stream.unfold({0, {positions, velocities}, MapSet.new()}, fn {counter, {p, v},
                                                                             previous} ->
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

  def get_axis(map, axis) do
    Enum.map(map, fn {k, v} -> {k, Map.get(v, axis)} end)
  end

  def find_repetition(acc, axis) do
    [{p, v} | tail] = acc

    first = {get_axis(p, axis), get_axis(v, axis)}

    1 +
      Enum.find_index(tail, fn {p, v} ->
        first == {get_axis(p, axis), get_axis(v, axis)}
      end)
  end

  # <x= 2, y=-1, z= 1>
  def parse_test_data(
        <<"<x=", x::binary-size(2), ", y=", y::binary-size(3), ", z=", z::binary-size(2), ">">>
      ) do
    parse_test_data(x, y, z)
  end

  def parse_test_data(
        <<"<x=", x::binary-size(2), ", y=", y::binary-size(2), ", z=", z::binary-size(2), ">">>
      ) do
    parse_test_data(x, y, z)
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

  def parse_test_data(x, y, z) do
    i = fn x -> x |> String.trim() |> String.to_integer() end

    Vector.new(i.(x), i.(y), i.(z))
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
