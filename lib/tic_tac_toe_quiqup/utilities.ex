defmodule TicTacToeQuiqup.Utilities do
  @moduledoc """
  Utility functions for TicTacToe Application
  """

  def generate_game_session_code(size \\ 3) do
    size
    |> :crypto.strong_rand_bytes()
    |> Base.encode32(case: :upper, padding: false)
  end
end
