defmodule TicTacToeQuiqupWeb.GameView do
  use TicTacToeQuiqupWeb, :view

  def render("show.json", %{session_code: session_code, state: state}) do
    %{
      data: %{
        session_code: session_code,
        players: state.players,
        board: parse_board(state.board),
        player_turn: state.player_turn,
        winner: state.winner,
        status: state.status
      }
    }
  end

  defp parse_board(board) do
    for {%{col: c, row: r}, v} <- board, do: %{col: c, row: r, value: v}
  end
end
