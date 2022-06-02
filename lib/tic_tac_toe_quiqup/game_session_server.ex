defmodule TicTacToeQuiqup.GameSessionServer do
  @moduledoc """
  A GenServer to manage different Game Sessions in the Server
  """

  @registry TicTacToeQuiqup.Registry

  alias TicTacToeQuiqup.{GamePlayer, GameSessionState, GameSquare}

  use GenServer

  @doc false
  def start_link([session_code: session_code, player: _player] = args) do
    case GenServer.start_link(
           __MODULE__,
           args,
           name: via_tuple(session_code)
         ) do
      {:ok, pid} -> {:ok, pid}
      {:error, {:already_started, pid}} -> {:ok, pid}
    end
  end

  @impl true
  def init(session_code: session_code, player: player),
    do: GameSessionState.event({:new_game, session_code, player})

  def play(game_session_state, row, col, player) do
    with {:ok, _player_letter} <- GamePlayer.validate_player(player),
         {:ok, square} <- GameSquare.new(row, col),
         {:ok, state} <- update_game_session(game_session_state, square, player),
         :continue <- winner(state.board, player.letter) do
      {:ok, state}
    else
      {:ok, player_letter} -> "#{player_letter} has won!"
      :tie -> "Game is a tie!"
      {:error, :occupied} -> "#{player.letter} try some other square!"
    end
  end

  defp update_game_session(game_session_state, square, player) do
    case check_square(game_session_state.board, square) do
      true ->
        latest_board =
          game_session_state.board
          |> Map.put(square, player.letter)

        {:ok, %{game_session_state | board: latest_board, next_turn: toggle_turn(player.letter)}}

      false ->
        {:error, :occupied}
    end
  end

  defp check_square(game_board, square), do: is_nil(Map.get(game_board, square))

  defp toggle_turn(:x), do: :o
  defp toggle_turn(:o), do: :x

  defp check_game_board(game_board) do
    case game_board |> Enum.any?(fn {_square, value} -> is_nil(value) end) do
      true -> :continue
      false -> :tie
    end
  end

  defp winner(board, player_letter) do
    rows = 1..3 |> Enum.map(&get_rows(board, &1))
    cols = 1..3 |> Enum.map(&get_cols(board, &1))
    diagonals = get_diagonals(board)

    result =
      (rows ++ cols ++ diagonals)
      |> Enum.any?(&check_winning_line(&1, player_letter))

    if result, do: {:ok, player_letter}, else: check_game_board(board)
  end

  defp get_rows(board, row), do: for({%{col: _c, row: r}, v} <- board, row == r, do: v)
  defp get_cols(board, col), do: for({%{col: c, row: _r}, v} <- board, col == c, do: v)

  defp get_diagonals(board),
    do: [
      for({%{col: c, row: r}, v} <- board, r == c, do: v),
      for({%{col: c, row: r}, v} <- board, 4 == c + r, do: v)
    ]

  def check_winning_line(line, player_letter), do: Enum.all?(line, &(player_letter == &1))

  defp via_tuple(name), do: {:via, Registry, {@registry, name}}
end
