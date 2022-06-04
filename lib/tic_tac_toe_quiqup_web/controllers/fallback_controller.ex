defmodule TicTacToeQuiqupWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use TicTacToeQuiqupWeb, :controller

  def call(conn, {:error, message}) do
    conn
    |> put_status(:bad_request)
    |> put_view(TicTacToeQuiqupWeb.ErrorView)
    |> render(:"4xx", error: message)
  end
end
