defmodule Puzzle3Test do
  use ExUnit.Case, async: true

  import Puzzle3

  describe "to_movement/1" do
    test "converts up" do
      assert {0, 1, 42} = to_movement("U42")
    end

    test "converts down" do
      assert {0, -1, 24} = to_movement("D24")
    end

    test "converts left" do
      assert {-1, 0, 337} = to_movement("L337")
    end

    test "converts right" do
      assert {1, 0, 2} = to_movement("R2")
    end
  end

  describe "path_to_points/1" do
    test "drive around the block" do
      path = [{1, 0, 1}, {0, 1, 1}, {-1, 0, 1}, {0, -1, 1}]

      points = path_to_points(path)

      assert Map.has_key?(points, {1, 0})
      assert Map.has_key?(points, {1, 1})
      assert Map.has_key?(points, {0, 1})
      assert Map.has_key?(points, {0, 0})
    end

    test "generates all the points in the segment" do
      points = path_to_points([{1, 0, 3}])

      assert Map.has_key?(points, {1, 0})
      assert Map.has_key?(points, {2, 0})
      assert Map.has_key?(points, {3, 0})
    end
  end

  describe "shortest_time/1" do
    test "requirements 1" do
      first_points = file_line_to_points("R75,D30,R83,U83,L12,D49,R71,U7,L72")
      second_points = file_line_to_points("U62,R66,U55,R34,D71,R55,D58,R83")

      assert 610 = shortest_time([first_points, second_points])
    end

    test "requirements 2" do
      first_points = file_line_to_points("R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51")
      second_points = file_line_to_points("U98,R91,D20,R16,D67,R40,U7,R15,U6,R7")

      assert 410 = shortest_time([first_points, second_points])
    end
  end

  describe "shortest_cross/1" do
    test "requirements 1" do
      first_points = file_line_to_points("R75,D30,R83,U83,L12,D49,R71,U7,L72")
      second_points = file_line_to_points("U62,R66,U55,R34,D71,R55,D58,R83")

      assert 159 = shortest_cross([first_points, second_points])
    end

    test "requirements 2" do
      first_points = file_line_to_points("R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51")
      second_points = file_line_to_points("U98,R91,D20,R16,D67,R40,U7,R15,U6,R7")

      assert 135 = shortest_cross([first_points, second_points])
    end
  end

  describe "from_input/2" do
    test "computes the shortest path from input" do
      assert 2427 = from_input("test/support/puzzle3/input.txt")
    end

    test "computes the fastest path from input" do
      assert 27890 = from_input("test/support/puzzle3/input.txt", :shortest_time)
    end
  end
end
