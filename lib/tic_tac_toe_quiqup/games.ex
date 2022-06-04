defmodule TicTacToeQuiqup.Games do
  @moduledoc """
  TicTacToeQuiqup Games Context for managing gaming sessions
  """

  import TicTacToeQuiqup.Utilities, only: [check_game_session_code: 1]

  alias TicTacToeQuiqup.{GamePlayer, GameSessionServer, GameSessionState}

  def create_game(session_code, player_name) do
    new_session_code = check_game_session_code(session_code)

    with {:ok, %GameSessionState{} = game_state} <- GameSessionServer.state(new_session_code),
         {:ok, old_player} <- GameSessionState.find_player(:name, game_state, player_name),
         {:ok, _state} <-
           GameSessionServer.start_or_join(session_code, old_player),
         {:ok, %GameSessionState{} = game_state} <- GameSessionServer.state(new_session_code) do
      {:ok, %{session_code: session_code, state: game_state, player: old_player}}
    else
      {:error, "Player not found!"} -> create_player_and_join_game(session_code, player_name)
      {:error, "Game not found!"} -> new_game(new_session_code, player_name)
      {:error, reason} -> {:error, reason}
    end
  end

  def get_game(session_code) do
    case GameSessionServer.state(session_code) do
      {:ok, %GameSessionState{} = state} ->
        {:ok, %{session_code: session_code, state: state}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def move(session_code, row, col, player_id) do
    case GameSessionServer.play(session_code, row, col, player_id) do
      {:ok, %GameSessionState{} = state} ->
        {:ok, %{session_code: session_code, state: state}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp create_player_and_join_game(session_code, player_name) do
    with {:ok, %GameSessionState{} = game_state} <- GameSessionServer.state(session_code),
         {:ok, player_letter} <- GameSessionState.player_letter(game_state),
         {:ok, new_player} <- GamePlayer.new(nil, player_name, player_letter),
         {:ok, _state} <-
           GameSessionServer.start_or_join(session_code, new_player),
         {:ok, %GameSessionState{} = game_state} <- GameSessionServer.state(session_code) do
      {:ok, %{session_code: session_code, state: game_state, player: new_player}}
    end
  end

  defp new_game(new_session_code, player_name) do
    with {:ok, new_player} <- GamePlayer.new_x(player_name),
         {:ok, _state} <-
           GameSessionServer.start_or_join(new_session_code, new_player),
         {:ok, %GameSessionState{} = game_state} <- GameSessionServer.state(new_session_code) do
      {:ok, %{session_code: new_session_code, state: game_state, player: new_player}}
    else
      {:error, reason} -> {:error, reason}
    end
  end
end
