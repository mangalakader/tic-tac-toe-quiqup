defmodule TicTacToeQuiqup.Games do
  @moduledoc """
  TicTacToeQuiqup Games Context for managing gaming sessions and adding application
  logic for managing games are to be done here
  """

  import TicTacToeQuiqup.Utilities, only: [check_game_session_code: 1]

  alias TicTacToeQuiqup.{GamePlayer, GameSessionServer, GameSessionState}
  alias TicTacToeQuiqup.Types.Errors
  alias TicTacToeQuiqup.Types.GameSquare, as: GameSquareSpec

  @spec create_game(binary() | nil, binary() | nil) :: {:ok, Enumerable.t()} | Errors.t()
  def create_game(session_code, player_name) do
    new_session_code = check_game_session_code(session_code)

    # if the game state is found (game is running), check if the player is already in the game,
    # allow the player to join the game

    with {:ok, %GameSessionState{} = game_state} <- GameSessionServer.state(new_session_code),
         {:ok, old_player} <- GameSessionState.find_player(:name, game_state, player_name),
         {:ok, _state} <-
           GameSessionServer.start_or_join(session_code, old_player),
         {:ok, %GameSessionState{} = game_state} <- GameSessionServer.state(new_session_code) do
      {:ok, %{session_code: session_code, state: game_state, player: old_player}}
    else
      # if the player is not found go to the player not found error clause, then creates the player
      # and join the game

      {:error, "Player not found!"} -> create_player_and_join_game(session_code, player_name)
      # if the game state is not found go to the game not found error clause, then creates a new game
      # and join the game using the player

      {:error, "Game not found!"} -> new_game(new_session_code, player_name)
      {:error, reason} -> {:error, reason}
    end
  end

  @spec get_game(binary()) :: {:ok, Enumerable.t()} | Errors.t()
  def get_game(session_code) do
    case GameSessionServer.state(session_code) do
      {:ok, %GameSessionState{} = state} ->
        {:ok, %{session_code: session_code, state: state}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @spec move(binary(), GameSquareSpec.board_size(), GameSquareSpec.board_size(), binary()) ::
          {:ok, Enumerable.t()} | Errors.t()
  def move(session_code, row, col, player_id) do
    case GameSessionServer.play(session_code, row, col, player_id) do
      {:ok, %GameSessionState{} = state} ->
        {:ok, %{session_code: session_code, state: state}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @spec create_player_and_join_game(binary() | nil, binary() | nil) ::
          {:ok, Enumerable.t()} | Errors.t()
  defp create_player_and_join_game(session_code, player_name) do
    with {:ok, %GameSessionState{} = game_state} <- GameSessionServer.state(session_code),
         {:ok, player_letter} <- GameSessionState.player_letter(game_state),
         {:ok, new_player} <- GamePlayer.new(nil, player_name, player_letter),
         {:ok, _state} <-
           GameSessionServer.start_or_join(session_code, new_player),
         {:ok, %GameSessionState{} = game_state} <- GameSessionServer.state(session_code) do
      {:ok, %{session_code: session_code, state: game_state, player: new_player}}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @spec new_game(binary() | nil, binary() | nil) :: {:ok, Enumerable.t()} | Errors.t()
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
