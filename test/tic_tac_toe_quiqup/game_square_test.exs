defmodule TicTacToeQuiqup.GameSquareTest do
  @moduledoc """
  Unit Tests for Game Square Module
  """

  use TicTacToeQuiqup.DataCase, async: true

  alias TicTacToeQuiqup.GameSquare

  describe "new/2" do
    test "row and col as user input" do
      assert {:ok, %GameSquare{row: 1, col: 1}} = GameSquare.new(1, 1)
    end

    test "invalid row and valid col as user input" do
      assert {:error, "Invalid game square"} = GameSquare.new(4, 1)
    end

    test "valid row and invalid col as user input" do
      assert {:error, "Invalid game square"} = GameSquare.new(1, 5)
    end

    test "invalid row and invalid col as user input" do
      assert {:error, "Invalid game square"} = GameSquare.new(4, 5)
    end
  end

  describe "new_game_board/0" do
    test "no user input" do
      assert %{
               %GameSquare{row: 1, col: 1} => nil,
               %GameSquare{row: 1, col: 2} => nil,
               %GameSquare{row: 1, col: 3} => nil,
               %GameSquare{row: 2, col: 1} => nil,
               %GameSquare{row: 2, col: 2} => nil,
               %GameSquare{row: 2, col: 3} => nil,
               %GameSquare{row: 3, col: 1} => nil,
               %GameSquare{row: 3, col: 2} => nil,
               %GameSquare{row: 3, col: 3} => nil
             } = GameSquare.new_game_board()
    end
  end
end
