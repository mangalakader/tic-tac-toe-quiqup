defmodule TicTacToeQuiqupWeb.PlayerLiveTest do
  use TicTacToeQuiqupWeb.ConnCase

  import Phoenix.LiveViewTest

  describe "Show Player Information Page" do
    @tag :live
    test "displays player info page", %{conn: conn} do
      assert {:ok, _show_live, _html} = live(conn, Routes.game_player_path(conn, :new))
    end

    @tag :live
    test "start game button text changes to join game on typing", %{conn: conn} do
      assert {:ok, view, _html} = live(conn, Routes.game_player_path(conn, :new))

      assert view
             |> element("form")
             |> render_change(%{
               player: %{
                 player_name: "LiveViewTest",
                 session_code: "SDFGH"
               }
             }) =~
               "Join Game"
    end

    @tag :live
    test "start a new game", %{conn: conn} do
      %{game: %{session_code: session_code, player: player}} = create_game("")

      player_one = %{
        "session_code" => session_code,
        "player_name" => player.name
      }

      {:ok, view, _html} = live(conn, Routes.game_player_path(conn, :new))

      {:ok, game_view, _html} =
        view
        |> form("form", player: player_one)
        |> render_submit()
        |> follow_redirect(
          conn,
          Routes.game_game_path(conn, :new, %{player_id: player.id, session_code: session_code})
        )

      assert page_title(game_view) =~ "Game ID: #{session_code} · Quiqup"
    end
  end
end
