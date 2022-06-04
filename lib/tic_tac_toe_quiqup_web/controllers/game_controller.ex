defmodule TicTacToeQuiqupWeb.GameController do
  use TicTacToeQuiqupWeb, :controller

  alias TicTacToeQuiqup.Games

  action_fallback TicTacToeQuiqupWeb.FallbackController

  def create(conn, %{
        "player_name" => player_name,
        "session_code" => session_code
      }) do
    with {:ok, %{session_code: session_code, state: state, player: _player}} <-
           Games.create_game(session_code, player_name) do
      conn
      |> put_status(:created)
      |> render("show.json", %{session_code: session_code, state: state})
    end
  end

  def create(_conn, _params), do: {:error, "Invalid Params!"}

  def show(conn, %{"id" => session_code}) do
    with {:ok, %{session_code: session_code, state: state}} <-
           Games.get_game(session_code) do
      conn
      |> put_status(200)
      |> render("show.json", %{session_code: session_code, state: state})
    end
  end

  def show(_conn, _params), do: {:error, "Invalid Params!"}

  def update(conn, %{
        "player_id" => player_id,
        "row" => row,
        "col" => col,
        "id" => session_code
      }) do
    with {:ok, %{session_code: session_code, state: state}} <-
           Games.move(session_code, row, col, player_id) do
      conn
      |> put_status(200)
      |> render("show.json", %{session_code: session_code, state: state})
    end
  end

  def update(_conn, _params), do: {:error, "Invalid Params!"}
end
