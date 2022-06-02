defmodule TicTacToeQuiqup.GameSessionServer do
  @moduledoc """
  A GenServer to manage different Game Sessions in the Server
  """

  alias TicTacToeQuiqup.{GamePlayer, GameSessionServer, GameSquare}

  use GenServer

  defstruct name: nil,
            player_one: nil,
            player_two: nil,
            board: nil,
            next_turn: nil,
            status: :not_started,
            winner: nil

  @doc false
  def start_link, do: GenServer.start_link(__MODULE__, Map.new())

  @impl true
  def init(state), do: {:ok, state}

  def play(game_session_state, row, col, player) do
    with {:ok, _player_letter} <- GamePlayer.validate_player(player),
         {:ok, square} <- GameSquare.new(row, col),
         {:ok, :success} <- check_player_turn(game_session_state, player),
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

  defp check_player_turn(%GameSessionServer{next_turn: l1}, %GamePlayer{letter: l2})
       when l1 == l2,
       do: {:ok, :success}

  defp check_player_turn(%GameSessionServer{next_turn: _l1}, %GamePlayer{letter: _l2}),
    do: {:error, :wait_for_turn}

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
end
