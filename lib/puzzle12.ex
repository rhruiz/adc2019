defmodule Puzzle12 do
  @moduledoc """
  Moons of Jupiter
  """

  def read_file do
    "test/support/puzzle12/input.txt"
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.map(&parse/1)
    |> Enum.into([])
  end

  def energy(position, velocity) do
    abs_sum = fn %Vector{x: x, y: y, z: z} ->
      abs(x) + abs(y) + abs(z)
    end

    potential = abs_sum.(position)
    kinetic = abs_sum.(velocity)

    potential * kinetic
  end

  def step(moons, positions) do
    velocities = Enum.zip(moons, Stream.cycle([Vector.new()]))
    step(moons, positions, velocities)
  end

  def step(moons, positions, velocities) do
    new_velocities =
      moons
      |> combinations(2)
      |> Enum.flat_map(fn [a, b] ->
        {da, db} = gravity_effect(positions[a], positions[b])

        [{a, da}, {b, db}]
      end)
      |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
      |> Enum.reduce(velocities, fn {moon, effects}, velocities ->
        update_in(velocities, [moon], fn velocity ->
          Enum.reduce(effects, velocity, &Vector.add/2)
        end)
      end)

    new_positions =
      Enum.into(moons, %{}, fn moon ->
        {moon, Vector.add(positions[moon], new_velocities[moon])}
      end)

    {new_positions, new_velocities}
  end

  defp gravity_effect(%Vector{} = a, %Vector{} = b) do
    ~w(x y z)a
    |> Enum.reduce({%Vector{}, %Vector{}}, fn axis, {acca, accb} ->
      {da, db} = gravity_effect(Map.get(a, axis), Map.get(b, axis))

      {
        Map.put(acca, axis, da),
        Map.put(accb, axis, db)
      }
    end)
  end

  defp gravity_effect(a, b) when a < b, do: {1, -1}
  defp gravity_effect(a, a), do: {0, 0}
  defp gravity_effect(_, _), do: {-1, 1}

  defp combinations(_, 0), do: [[]]
  defp combinations([], _), do: []

  defp combinations([head | tail], size) do
    for(elem <- combinations(tail, size - 1), do: [head | elem]) ++ combinations(tail, size)
  end

  # <x=-5, y=6, z=-11>
  defp parse(line) do
    line
    |> String.trim(">")
    |> String.split(", ")
    |> Enum.map(fn coordinates ->
      coordinates
      |> String.split("=", trim: true)
      |> Enum.at(1)
      |> String.to_integer()
    end)
    |> (fn coordinates -> apply(Vector, :new, coordinates) end).()
  end
end
