defmodule TicTacToeQuiqup.Utilities do
  @moduledoc """
  Utility functions for TicTacToe Application
  """

  def generate_rand_str(size \\ 12) do
    size
    |> :crypto.strong_rand_bytes()
    |> Base.encode32(case: :upper, padding: false)
  end

  def check_game_session_code(session_code, size \\ 3)

  def check_game_session_code(nil, size), do: generate_rand_str(size)
  def check_game_session_code("", size), do: generate_rand_str(size)
  def check_game_session_code(session_code, _size), do: session_code
end
