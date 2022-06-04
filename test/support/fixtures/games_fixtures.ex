defmodule TicTacToeQuiqup.GamesFixtures do
  @moduledoc """
  This module defines test helpers
  """

  alias TicTacToeQuiqup.{Games, GameSquare}

  def winning_game_board(letter \\ :x) do
    toggled_letter = if letter == :x, do: :o, else: :x

    %{
      %GameSquare{row: 1, col: 1} => letter,
      %GameSquare{row: 1, col: 2} => letter,
      %GameSquare{row: 1, col: 3} => letter,
      %GameSquare{row: 2, col: 1} => toggled_letter,
      %GameSquare{row: 2, col: 2} => nil,
      %GameSquare{row: 2, col: 3} => nil,
      %GameSquare{row: 3, col: 1} => toggled_letter,
      %GameSquare{row: 3, col: 2} => nil,
      %GameSquare{row: 3, col: 3} => nil
    }
  end

  def tie_game_board(letter \\ :x) do
    toggled_letter = if letter == :x, do: :o, else: :x

    %{
      %GameSquare{row: 1, col: 1} => letter,
      %GameSquare{row: 1, col: 2} => letter,
      %GameSquare{row: 1, col: 3} => toggled_letter,
      %GameSquare{row: 2, col: 1} => toggled_letter,
      %GameSquare{row: 2, col: 2} => toggled_letter,
      %GameSquare{row: 2, col: 3} => letter,
      %GameSquare{row: 3, col: 1} => letter,
      %GameSquare{row: 3, col: 2} => toggled_letter,
      %GameSquare{row: 3, col: 3} => letter
    }
  end

  def game_board(letter \\ :x, row, col) do
    {:ok, game_square} = GameSquare.new(row, col)
    GameSquare.new_game_board() |> Map.put(game_square, letter)
  end

  def update_game_board(letter, row, col, board) do
    {:ok, game_square} = GameSquare.new(row, col)
    board |> Map.put(game_square, letter)
  end

  def create_game(_args) do
    {:ok, game} = Games.create_game("", "Test Player 1")
    %{game: game}
  end
end
