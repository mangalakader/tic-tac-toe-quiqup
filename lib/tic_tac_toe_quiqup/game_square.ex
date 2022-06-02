defmodule TicTacToeQuiqup.GameSquare do
  @moduledoc """
  TicTacToe GameSquare Board Functions
  """

  alias __MODULE__

  @enforce_keys [:row, :col]

  defstruct row: nil, col: nil, occupied_by: nil

  def new(row, col) when row in 1..3 and col in 1..3, do: {:ok, %GameSquare{row: row, col: col}}
  def new(_row, _col), do: {:error, :invalid_game_square}
end
