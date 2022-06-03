defmodule TicTacToeQuiqup.Games do
  @moduledoc """
  TicTacToeQuiqup Games Context for managing gaming sessions
  """

  import TicTacToeQuiqup.Utilities,
    only: [generate_game_session_code: 0, generate_game_session_code: 1]

  alias TicTacToeQuiqup.{GamePlayer, GameSessionServer, GameSessionState}

  def create_game(player_name, letter, session_code \\ generate_game_session_code()) do
    with %GamePlayer{} = player <-
           GamePlayer.new(generate_game_session_code(12), player_name, letter),
         {:ok, _started} <- GameSessionServer.start_or_join(session_code, player),
         %GameSessionState{} = state <- GameSessionServer.state(session_code) do
      {:ok, %{session_code: session_code, state: state}}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def get_game(session_code) do
    case GameSessionServer.state(session_code) do
      %GameSessionState{} = state ->
        {:ok, %{session_code: session_code, state: state}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def move(session_code, row, col, player_id) do
    case GameSessionServer.play(session_code, row, col, player_id) do
      %GameSessionState{} = state ->
        {:ok, %{session_code: session_code, state: state}}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
