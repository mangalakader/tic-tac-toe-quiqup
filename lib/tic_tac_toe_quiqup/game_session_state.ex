defmodule TicTacToeQuiqup.GameSessionState do
  @moduledoc """
  TicTacToe Game State Machine for handling different states using
  events based setup and processing the state based on different
  criteria.

  Game Session State Events are used to modify the current state of the game
  based on different actions and it is used to derieve the results of the game

  Defined Actions for the game are: 
    
    1. :start_game - Starts a game with new empty state
    
    2. :join_game - Join a game with existing state
    
    3. :place - Capture Game Square with existing state

  Defined Statues for the game are: 
    
    1. :not_started - Game is not started yet
    
    2. :playing - Game has atleast 1 player in the game
    
    3. :game_over - Game is complete either by a win or a tie

  Any other actions will result in an error for the current action but the game session
  will be maintained until the game is ended due to inactivity

  The errors that can occur are as follows:

    1. `{:error, "Game not found!"}` 

    This error occurs when the game is not started and according to the game flow
    any game should start with atleast 1 player and if the player list is empty and
    you try to join the game, then this error occurs

    2. `{:error, "Game completed!"}` 

    This error occurs when the game is completed by a tie or a win and if the game
    status is game_over and you try to do any action, then this error occurs
    
    3. `{:error, "Game can be played only by maximum of 2 players"}`

    This error occurs when the game has 2 players already and you try to join the 
    game, then this error occurs
    
    4. `{:error, "Waiting for player 2"}`
    
    This error occurs when the game has 1 player and the player tries to play the game
    
    5. `{:error, "Game has already started"}`
    
    This error occurs when the game has already started with 1 player and 
    you try to start the game again. A game can be started only once.

    6. `{:error, "Player not found!"}`

    This error occurs when an invalid player tried to play the game
    
    7. `{:error, "Square already taken by a player!"}`
    
    This error occurs when a player tries to take over the location which has
    been taken by another player

    8. `{:error, %{reason: :invalid_game_state_transition, state: _state, action: _action}}`
    
    This error occurs when you try to perform an action that is not defined
  """

  alias TicTacToeQuiqup.{GamePlayer, GameSessionState, GameSquare}

  alias TicTacToeQuiqup.Types.Errors
  alias TicTacToeQuiqup.Types.GamePlayer, as: GamePlayerSpec
  alias TicTacToeQuiqup.Types.GameSessionState, as: GameSessionStateSpec
  alias TicTacToeQuiqup.Types.GameSquare, as: GameSquareSpec

  defstruct session_code: nil,
            status: :not_started,
            players: [],
            player_turn: nil,
            winner: nil,
            inactivity_timer_ref: nil,
            board: GameSquare.new_game_board()

  @doc """
  Event function GameSessionState struct and an action as input and performs the action
  on the game state and return the state.

  If game state is not passed, it takes empty game state as default argument
  """
  @spec event(GameSessionStateSpec.t() | any(), GameSessionStateSpec.action()) ::
          {:ok, GameSessionStateSpec.t()} | Errors.t()

  def event(state \\ %GameSessionState{}, action)

  def event(%GameSessionState{players: []}, {:join_game, _player}),
    do: {:error, "Game not found!"}

  def event(%GameSessionState{status: :game_over, players: [_p1, _p2]}, {:join_game, _player}),
    do: {:error, "Game completed!"}

  def event(%GameSessionState{players: [_p1, _p2]}, {:join_game, _player}),
    do: {:error, "Game can be played only by maximum of 2 players"}

  def event(%GameSessionState{players: [p1]} = state, {:join_game, p2}) when p1 != p2 do
    p2 = %{p2 | letter: toggle_letter(p1.letter)}
    {:ok, %{state | players: [p1, p2]}} |> reset_inactivity_time()
  end

  def event(%GameSessionState{players: [_p1]} = state, {:join_game, _p2}),
    do: {:ok, state} |> reset_inactivity_time()

  def event(%GameSessionState{status: :playing}, {:start_game, _code, _player}),
    do: {:error, "Game has already started"}

  def event(%GameSessionState{status: :game_over}, _any_action),
    do: {:error, "Game completed!"}

  def event(
        %GameSessionState{status: :not_started, players: []} = state,
        {:start_game, session_code, player}
      ) do
    {:ok,
     %{
       state
       | session_code: session_code,
         status: :playing,
         player_turn: player.letter,
         players: [player]
     }}
    |> reset_inactivity_time()
  end

  def event(
        %GameSessionState{status: :playing, players: [_p1]},
        _action
      ),
      do: {:error, "Waiting for player 2"}

  def event(
        %GameSessionState{status: :playing} = state,
        {:place, row, col, player_id}
      ) do
    with {:ok, player} <- find_player(state, player_id),
         {:ok, square} <- GameSquare.new(row, col),
         {:ok, new_state} <- update_game_session_state(state, square, player) do
      {:ok, reset_inactivity_time(new_state)}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def event(state, action),
    do: {:error, %{reason: :invalid_game_state_transition, state: state, action: action}}

  @doc """
  When the game is started, it starts with timeout for the game end due to inactivity and
  for any valid action, the player performs, the timeout is reset and the state is returned
  """
  @spec reset_inactivity_time({:ok, GameSessionStateSpec.t()} | GameSessionStateSpec.t()) ::
          {:ok, GameSessionStateSpec.t()} | GameSessionStateSpec.t()
  def reset_inactivity_time({:ok, %GameSessionState{inactivity_timer_ref: _ref} = state}),
    do: {:ok, reset_inactivity_time(state)}

  def reset_inactivity_time(%GameSessionState{inactivity_timer_ref: ref} = state)
      when is_nil(ref) do
    %{state | inactivity_timer_ref: Process.send_after(self(), :end_game, inactivity_timeout())}
  end

  def reset_inactivity_time(%GameSessionState{inactivity_timer_ref: ref} = state) do
    Process.cancel_timer(ref)
    %{state | inactivity_timer_ref: Process.send_after(self(), :end_game, inactivity_timeout())}
  end

  @doc """
  Find player for a particular game by `player id` from the game state
  """
  @spec find_player(GameSessionStateSpec.t(), binary()) :: {:ok, GamePlayerSpec.t()} | Errors.t()
  def find_player(%GameSessionState{players: players} = _state, player_id) do
    case Enum.find(players, &(&1.id == player_id)) do
      nil ->
        {:error, "Player not found!"}

      %GamePlayer{} = player ->
        {:ok, player}
    end
  end

  @doc """
  Find player for a particular game by `player name` from the game state
  """
  @spec find_player(:name, GameSessionStateSpec.t(), binary()) ::
          {:ok, GamePlayerSpec.t()} | Errors.t()
  def find_player(:name, %GameSessionState{players: players} = _state, player_name) do
    case Enum.find(players, &(&1.name == player_name)) do
      nil ->
        {:error, "Player not found!"}

      %GamePlayer{} = player ->
        {:ok, player}
    end
  end

  def find_player(_any, _state, _player_name), do: {:error, "Player not found!"}

  @doc """
  Determine the player letter based on the game state, always the first player to start
  the game gets `:x` and the next player gets `:o`
  """
  @spec player_letter(GameSessionStateSpec.t()) ::
          {:ok, GameSessionStateSpec.player_letters()} | Errors.t()
  def player_letter(%GameSessionState{players: players}) do
    players_size = length(players)

    cond do
      players_size == 0 -> {:ok, :x}
      players_size == 1 -> {:ok, players |> List.first() |> Map.get(:letter) |> toggle_letter()}
      true -> {:error, "Game can be played only by maximum of 2 players"}
    end
  end

  @spec inactivity_timeout() :: integer() | nil
  defp inactivity_timeout,
    do: Application.get_env(:tic_tac_toe_quiqup, __MODULE__) |> Keyword.get(:inactivity_timeout)

  @spec toggle_letter(GameSessionStateSpec.player_letters()) ::
          GameSessionStateSpec.player_letters()
  defp toggle_letter(:x), do: :o
  defp toggle_letter(:o), do: :x

  @spec update_game_session_state(
          GameSessionStateSpec.t(),
          GameSquareSpec.t(),
          GamePlayerSpec.t()
        ) :: {:ok, GameSessionStateSpec.t()} | Errors.t()
  defp update_game_session_state(%GameSessionState{board: game_board} = state, square, player) do
    if check_square(game_board, square) do
      updated_game_board = game_board |> Map.put(square, player.letter)

      case winner(updated_game_board, player.letter) do
        {:ok, :continue} ->
          {:ok, %{state | board: updated_game_board, player_turn: toggle_letter(player.letter)}}

        {:ok, :tie} ->
          {:ok, %{state | board: updated_game_board, player_turn: nil, status: :game_over}}

        {:ok, :winner} ->
          {:ok,
           %{
             state
             | board: updated_game_board,
               player_turn: nil,
               status: :game_over,
               winner: player.letter
           }}
      end
    else
      {:error, "Square already taken by a player!"}
    end
  end

  @spec check_square(Enumerable.t(), GameSquareSpec.t()) :: boolean()
  defp check_square(game_board, square), do: is_nil(Map.get(game_board, square))

  @spec check_game_board(Enumerable.t()) :: {:ok, GameSessionStateSpec.gameplay_status()}
  defp check_game_board(game_board) do
    case game_board |> Enum.any?(fn {_square, value} -> is_nil(value) end) do
      true -> {:ok, :continue}
      false -> {:ok, :tie}
    end
  end

  @spec winner(Enumerable.t(), GameSessionStateSpec.player_letters()) ::
          {:ok, GameSessionStateSpec.gameplay_status()}
  defp winner(board, player_letter) do
    rows = 1..3 |> Enum.map(&get_rows(board, &1))
    cols = 1..3 |> Enum.map(&get_cols(board, &1))
    diagonals = get_diagonals(board)

    result =
      (rows ++ cols ++ diagonals)
      |> Enum.any?(&check_winning_line(&1, player_letter))

    if result, do: {:ok, :winner}, else: check_game_board(board)
  end

  @spec get_rows(Enumerable.t(), GameSquareSpec.board_size()) :: [
          GameSessionStateSpec.player_letters() | nil
        ]
  defp get_rows(board, row), do: for({%{col: _c, row: r}, v} <- board, row == r, do: v)

  @spec get_cols(Enumerable.t(), GameSquareSpec.board_size()) :: [
          GameSessionStateSpec.player_letters() | nil
        ]
  defp get_cols(board, col), do: for({%{col: c, row: _r}, v} <- board, col == c, do: v)

  @spec get_diagonals(Enumerable.t()) :: [[GameSessionStateSpec.player_letters() | nil]]
  defp get_diagonals(board),
    do: [
      for({%{col: c, row: r}, v} <- board, r == c, do: v),
      for({%{col: c, row: r}, v} <- board, 4 == c + r, do: v)
    ]

  @spec check_winning_line(
          [GameSessionStateSpec.player_letters() | nil],
          GameSessionStateSpec.player_letters()
        ) :: boolean()
  defp check_winning_line(line, player_letter), do: Enum.all?(line, &(player_letter == &1))
end
