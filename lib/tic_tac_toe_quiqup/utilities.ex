defmodule TicTacToeQuiqup.Utilities do
  @moduledoc """
  Utility functions for TicTacToe Application
  """

  @doc """
  Generate Random String function takes an integer as an input
  and returns a binary of the size of the integer

  ## Examples

    ```elixir
    iex> random_string = TicTacToeQuiqup.Utilities.generate_rand_str(12)
    iex> byte_size(random_string) == 12

    ```
  """
  @spec generate_rand_str(integer()) :: binary()
  def generate_rand_str(size \\ 12) do
    size
    |> :crypto.strong_rand_bytes()
    |> Base.encode32(case: :upper, padding: false)
  end

  @doc """
  Check game session code function takes a string and an optional integer 
  as inputs and returns a new binary of the size of the optional integer or
  validates the string input for nil or empty string

  ## Examples

    ```elixir
    iex> session_code = TicTacToeQuiqup.Utilities.check_game_session_code(nil, 3)
    iex> byte_size(session_code) == 3

    iex> session_code = TicTacToeQuiqup.Utilities.check_game_session_code("", 3)
    iex> byte_size(session_code) == 3

    iex> session_code = TicTacToeQuiqup.Utilities.check_game_session_code("HELLO", 12)
    iex> session_code == "HELLO"
    ```
  """
  @spec check_game_session_code(binary(), integer()) :: binary()
  def check_game_session_code(session_code, size \\ 3)

  def check_game_session_code(nil, size), do: generate_rand_str(size)
  def check_game_session_code("", size), do: generate_rand_str(size)
  def check_game_session_code(session_code, _size), do: session_code
end
