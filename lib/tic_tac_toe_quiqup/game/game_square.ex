defmodule TicTacToeQuiqup.GameSquare do
  @moduledoc """
  TicTacToe GameSquare Board Functions and any validations or
  functional logics related to single game square has to be done
  through here
  """

  alias __MODULE__

  alias TicTacToeQuiqup.Types.Errors
  alias TicTacToeQuiqup.Types.GameSquare, as: GameSquareSpec

  @enforce_keys [:row, :col]

  defstruct row: nil, col: nil

  @doc """
  GameSquare new function takes row and column as input
  and returns GameSquare struct or error if the row and column
  is not with 1 and 3.

  ## Examples

  Using the new function to create new GameSquare

  ```elixir
    iex> TicTacToeQuiqup.GameSquare.new(3, 3)
    {:ok, %TicTacToeQuiqup.GameSquare{col: 3, row: 3}}

  ```

  When the board size is mistmatched it return an error

  ```elixir
    iex> TicTacToeQuiqup.GameSquare.new(3, 4)
    {:error, "Invalid game square"}

  ```
  """
  @spec new(GameSquareSpec.board_size(), GameSquareSpec.board_size()) ::
          {:ok, GameSquareSpec.t()} | Errors.t()
  def new(row, col) when row in 1..3 and col in 1..3, do: {:ok, %GameSquare{row: row, col: col}}
  def new(_row, _col), do: {:error, "Invalid game square"}

  @doc """
  GameSquare new_game_board function takes no arguements
  and returns a new empty game board a map with 9 Game Squares

  ## Examples

  Using the new game board function

  ```elixir
    iex> TicTacToeQuiqup.GameSquare.new_game_board()
    %{
      %TicTacToeQuiqup.GameSquare{col: 1, row: 1} => nil,
      %TicTacToeQuiqup.GameSquare{col: 1, row: 2} => nil,
      %TicTacToeQuiqup.GameSquare{col: 1, row: 3} => nil,
      %TicTacToeQuiqup.GameSquare{col: 2, row: 1} => nil,
      %TicTacToeQuiqup.GameSquare{col: 2, row: 2} => nil,
      %TicTacToeQuiqup.GameSquare{col: 2, row: 3} => nil,
      %TicTacToeQuiqup.GameSquare{col: 3, row: 1} => nil,
      %TicTacToeQuiqup.GameSquare{col: 3, row: 2} => nil,
      %TicTacToeQuiqup.GameSquare{col: 3, row: 3} => nil
    }

  ```
  """
  @spec new_game_board() :: Enumerable.t()
  def new_game_board do
    for(
      c <- 1..3,
      r <- 1..3,
      into: %{},
      do: {%GameSquare{row: r, col: c}, nil}
    )
  end
end
