defmodule Puzzle25 do
  @moduledoc """
  Bot weighting
  """

  use Bitwise

  import IntcodeRunner, only: [ascii_output: 1, ascii_input: 2]

  @n "north"
  @s "south"
  @w "west"
  @e "east"

  @clockwise %{
    @n => @e,
    @e => @s,
    @s => @w,
    @w => @n
  }

  @counterclock %{
    @n => @w,
    @w => @s,
    @s => @e,
    @e => @n
  }

  @do_not_want ["photons", "infinite loop", "escape pod", "molten lava", "giant electromagnet"]

  def navigate do
    maze =
      "test/support/puzzle25/input.txt"
      |> Intcode.read_file()
      |> IntcodeRunner.start_link_ascii()

    position = "Hull Breach"
    next = @s
    inventory = MapSet.new()
    ascii_output(maze)

    navigate(maze, {position, next}, inventory)
  end

  def navigate(maze, {"Hull Breach" = position, @e}, inventory) do
    to_security(maze, position, @s, inventory)
  end

  def navigate(maze, {position, direction}, inventory) do
    case move(maze, position, direction, inventory) do
      {^position, inventory} ->
        navigate(maze, {position, @counterclock[direction]}, inventory)

      {new_position, inventory} ->
        navigate(maze, {new_position, @clockwise[direction]}, inventory)
    end
  end

  def brute_force(maze, inventory) do
    possibles = Range.new(0, (1 <<< MapSet.size(inventory)) - 1)
    inventory = Enum.to_list(inventory)

    Enum.each(inventory, fn item ->
      ascii_input(maze, "drop #{item}")
      ascii_output(maze)
    end)

    Enum.find_value(possibles, fn candidate ->
      pick_up =
        inventory
        |> Enum.with_index()
        |> Enum.filter(fn {_item, index} ->
          (candidate &&& 1 <<< index) > 0
        end)
        |> Enum.map(fn {item, _index} -> item end)

      Enum.each(pick_up, fn item ->
        ascii_input(maze, "take #{item}")
        ascii_output(maze)
      end)

      ascii_input(maze, "west")
      output = ascii_output(maze)

      if !String.contains?(output, "Droids on this ship are lighter than the detected value") &&
           !String.contains?(output, "Droids on this ship are heavier than the detected value") do
        output
      else
        Enum.each(pick_up, fn item ->
          ascii_input(maze, "drop #{item}")
          ascii_output(maze)
        end)

        false
      end
    end)
  end

  def to_security(maze, position, direction, inventory) do
    case move(maze, position, direction, inventory) do
      {^position, inventory} ->
        to_security(maze, position, @counterclock[direction], inventory)

      {"Security Checkpoint", inventory} ->
        brute_force(maze, inventory)

      {new_position, inventory} ->
        to_security(maze, new_position, @clockwise[direction], inventory)
    end
  end

  def move(_maze, "Security Checkpoint" = position, "west", inventory) do
    {position, inventory}
  end

  def move(maze, position, direction, inventory) do
    ascii_input(maze, direction)
    output = ascii_output(maze)

    if String.contains?(output, "You can't go that way") do
      {position, inventory}
    else
      location = Regex.named_captures(~r/== (?<location>[\w ]+) ==/m, output)["location"]

      inventory =
        case Regex.named_captures(~r/Items here:\n(?:\- (?<item>[^\n]+)\n)+/, output) do
          nil ->
            inventory

          %{"item" => item} when item in @do_not_want ->
            inventory

          %{"item" => item} ->
            ascii_input(maze, "take #{String.trim(item)}")
            ascii_output(maze)

            MapSet.put(inventory, String.trim(item))
        end

      {location, inventory}
    end
  end
end
