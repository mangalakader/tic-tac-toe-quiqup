defmodule TicTacToeQuiqup.GameSessionState do
  @moduledoc """
  TicTacToe Game State Machine for handling different states
  """

  alias TicTacToeQuiqup.{GamePlayer, GameSessionState, GameSquare}

  # After 2 minutes, game is ended
  @inactivity_timer 1000 * 60 * 2

  defstruct session_code: nil,
            status: :not_started,
            players: [],
            player_turn: nil,
            winner: nil,
            inactivity_timer_ref: nil,
            board: GameSquare.new_game_board()

  def event(state \\ %GameSessionState{}, action)

  def event(%GameSessionState{players: []}, {:join_game, _player}),
    do: {:error, "Game not found!"}

  def event(%GameSessionState{status: :game_over, players: [_p1, _p2]}, {:join_game, _player}),
    do: {:error, "Game completed!"}

  def event(%GameSessionState{players: [_p1, _p2]}, {:join_game, _player}),
    do: {:error, "Game can be played only by maximum of 2 players"}

  def event(%GameSessionState{players: [p1]} = state, {:join_game, p2}) when p1 != p2 do
    p2 = %{p2 | letter: toggle_turn(p1.letter)}
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

  def reset_inactivity_time({:ok, %GameSessionState{inactivity_timer_ref: _ref} = state}),
    do: {:ok, reset_inactivity_time(state)}

  def reset_inactivity_time(%GameSessionState{inactivity_timer_ref: ref} = state)
      when is_nil(ref) do
    %{state | inactivity_timer_ref: Process.send_after(self(), :end_game, @inactivity_timer)}
  end

  def reset_inactivity_time(%GameSessionState{inactivity_timer_ref: ref} = state) do
    Process.cancel_timer(ref)
    %{state | inactivity_timer_ref: Process.send_after(self(), :end_game, @inactivity_timer)}
  end

  def find_player(%GameSessionState{players: players} = _state, player_id) do
    case Enum.find(players, &(&1.id == player_id)) do
      nil ->
        {:error, "Player not found!"}

      %GamePlayer{} = player ->
        {:ok, player}
    end
  end

  def find_player(:name, %GameSessionState{players: players} = _state, player_name) do
    case Enum.find(players, &(&1.name == player_name)) do
      nil ->
        {:error, "Player not found!"}

      %GamePlayer{} = player ->
        {:ok, player}
    end
  end

  def player_letter(%GameSessionState{players: players}) do
    players_size = length(players)

    cond do
      players_size == 0 -> {:ok, :x}
      players_size == 1 -> {:ok, players |> List.first() |> Map.get(:letter) |> toggle_turn()}
      true -> {:error, "Game can be played only by maximum of 2 players"}
    end
  end

  defp toggle_turn(:x), do: :o
  defp toggle_turn(:o), do: :x

  defp update_game_session_state(%GameSessionState{board: game_board} = state, square, player) do
    if check_square(game_board, square) do
      updated_game_board = game_board |> Map.put(square, player.letter)

      case winner(updated_game_board, player.letter) do
        {:ok, :continue} ->
          {:ok, %{state | board: updated_game_board, player_turn: toggle_turn(player.letter)}}

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

  defp check_square(game_board, square), do: is_nil(Map.get(game_board, square))

  defp check_game_board(game_board) do
    case game_board |> Enum.any?(fn {_square, value} -> is_nil(value) end) do
      true -> {:ok, :continue}
      false -> {:ok, :tie}
    end
  end

  defp winner(board, player_letter) do
    rows = 1..3 |> Enum.map(&get_rows(board, &1))
    cols = 1..3 |> Enum.map(&get_cols(board, &1))
    diagonals = get_diagonals(board)

    result =
      (rows ++ cols ++ diagonals)
      |> Enum.any?(&check_winning_line(&1, player_letter))

    if result, do: {:ok, :winner}, else: check_game_board(board)
  end

  defp get_rows(board, row), do: for({%{col: _c, row: r}, v} <- board, row == r, do: v)
  defp get_cols(board, col), do: for({%{col: c, row: _r}, v} <- board, col == c, do: v)

  defp get_diagonals(board),
    do: [
      for({%{col: c, row: r}, v} <- board, r == c, do: v),
      for({%{col: c, row: r}, v} <- board, 4 == c + r, do: v)
    ]

  def check_winning_line(line, player_letter), do: Enum.all?(line, &(player_letter == &1))
end
