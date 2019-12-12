defmodule Puzzle12Test do
  use ExUnit.Case, async: true

  import Puzzle12

  @moons [:io, :europa, :ganymede, :callisto]

  describe "step/3" do
    test "matches start 1 requirement 1" do
      data =
        """
        pos=<x=-1, y=  0, z= 2>, vel=<x= 0, y= 0, z= 0>
        pos=<x= 2, y=-10, z=-7>, vel=<x= 0, y= 0, z= 0>
        pos=<x= 4, y= -8, z= 8>, vel=<x= 0, y= 0, z= 0>
        pos=<x= 3, y=  5, z=-1>, vel=<x= 0, y= 0, z= 0>
        """

      {positions, velocities} =
        data
        |> String.trim()
        |> String.split("\n")
        |> Enum.map(&parse_test_data/1)
        |> Enum.zip(@moons)
        |> Enum.reduce({%{}, %{}}, fn {{pos, vel}, moon}, {poss, vels} ->
          {
            Map.put(poss, moon, pos),
            Map.put(vels, moon, vel)
          }
        end)

      assert {p, v} = step(@moons, positions, velocities)
      assert {2, -1, 1} = Vector.coordinates(p.io)
      assert {3, -7, -4} = Vector.coordinates(p.europa)
      assert {1, -7, 5} = Vector.coordinates(p.ganymede)
      assert {2, 2, 0} = Vector.coordinates(p.callisto)

      assert {3, -1, -1} = Vector.coordinates(v.io)
      assert {1, 3, 3} = Vector.coordinates(v.europa)
      assert {-3, 1, -3} = Vector.coordinates(v.ganymede)
      assert {-1, -3, 1} = Vector.coordinates(v.callisto)
    end
  end

  # pos=<x= 2, y=-1, z= 1>, vel=<x= 3, y=-1, z=-1>
  def parse_test_data(<<"pos=<x=", x::binary-size(2), ", y=", y::binary-size(3), ", z=", z::binary-size(2), ">, vel=<x=", vx::binary-size(2), ", y=", vy::binary-size(2), ", z=", vz::binary-size(2), ">">>) do
    i = fn x -> x |> String.trim() |> String.to_integer() end

    {Vector.new(i.(x), i.(y), i.(z)), Vector.new(i.(vx), i.(vy), i.(vz))}
  end

  def parse_test_data(<<"pos=<x=", x::binary-size(2), ", y=", y::binary-size(2), ", z=", z::binary-size(2), ">, vel=<x=", vx::binary-size(2), ", y=", vy::binary-size(2), ", z=", vz::binary-size(2), ">">>) do
    i = fn x -> x |> String.trim() |> String.to_integer() end

    {Vector.new(i.(x), i.(y), i.(z)), Vector.new(i.(vx), i.(vy), i.(vz))}
  end
end
