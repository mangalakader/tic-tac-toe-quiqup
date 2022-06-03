defmodule TicTacToeQuiqupWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use TicTacToeQuiqupWeb, :controller

  # This clause is an example of how to handle resources that cannot be found.
  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(TicTacToeQuiqupWeb.ErrorView)
    |> render(:"404")
  end

  def call(conn, {:error, message}) do
    conn
    |> put_status(:bad_request)
    |> put_view(TicTacToeQuiqupWeb.ErrorView)
    |> render(:"400", error: message)
  end
end
