defmodule TicTacToeQuiqup.Types.GameSquare do
  @moduledoc """
  Type Specs for GameSquare Module
  """

  @type board_size() :: 1 | 2 | 3

  @type t() :: %TicTacToeQuiqup.GameSquare{row: board_size() | nil, col: board_size() | nil}
end
