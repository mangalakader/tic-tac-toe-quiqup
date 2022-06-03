defmodule TicTacToeQuiqupWeb.GameController do
  use TicTacToeQuiqupWeb, :controller

  import TicTacToeQuiqup.Utilities, only: [generate_game_session_code: 0]

  alias TicTacToeQuiqup.Games

  action_fallback TicTacToeQuiqupWeb.FallbackController

  def create(conn, %{
        "player_name" => player_name,
        "letter" => letter,
        "session_code" => session_code
      }) do
    session_code =
      if session_code == "" or is_nil(session_code),
        do: generate_game_session_code(),
        else: session_code

    with {:ok, %{session_code: session_code, state: state}} <-
           Games.create_game(player_name, letter, session_code) do
      conn
      |> put_status(:created)
      |> render("show.json", %{session_code: session_code, state: state})
    end
  end

  def show(conn, %{"id" => session_code}) do
    with {:ok, %{session_code: session_code, state: state}} <-
           Games.get_game(session_code) do
      conn
      |> put_status(200)
      |> render("show.json", %{session_code: session_code, state: state})
    end
  end

  def update(conn, %{
        "player_id" => player_id,
        "row" => row,
        "col" => col,
        "session_code" => session_code
      }) do
    with {:ok, %{session_code: session_code, state: state}} <-
           Games.move(session_code, row, col, player_id) do
      conn
      |> put_status(200)
      |> render("show.json", %{session_code: session_code, state: state})
    end
  end
end
