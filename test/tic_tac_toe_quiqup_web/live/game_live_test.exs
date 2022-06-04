defmodule TicTacToeQuiqupWeb.GameLiveTest do
  use TicTacToeQuiqupWeb.ConnCase

  import Phoenix.LiveViewTest
  alias TicTacToeQuiqup.Games

  describe "Show Game Page for Players" do
    setup [:create_game]

    @tag :live
    test "displays game page", %{
      conn: conn,
      game: %{session_code: session_code, player: player_one}
    } do
      {:ok, game_view, _html} =
        live(
          conn,
          Routes.game_game_path(conn, :new, session_code: session_code, player_id: player_one.id)
        )

      assert page_title(game_view) =~ "Game ID: #{session_code} · Quiqup"
    end

    @tag :live
    test "displays game page for player 2", %{
      conn: conn,
      game: %{session_code: session_code, player: player_one}
    } do
      {:ok, game_view, _html} =
        live(
          conn,
          Routes.game_game_path(conn, :new, session_code: session_code, player_id: player_one.id)
        )

      assert page_title(game_view) =~ "Game ID: #{session_code} · Quiqup"

      {:ok, %{state: %{players: players}, player: player_two}} =
        Games.create_game(session_code, "Test Player 2")

      assert length(players) == 2

      {:ok, game_view_2, _html} =
        live(
          conn,
          Routes.game_game_path(conn, :new, session_code: session_code, player_id: player_two.id)
        )

      assert page_title(game_view_2) =~ "Game ID: #{session_code} · Quiqup"
    end

    @tag :live
    test "Each players makes a move", %{
      conn: conn,
      game: %{session_code: session_code, player: player_one}
    } do
      {:ok, game_view, _html} =
        live(
          conn,
          Routes.game_game_path(conn, :new, session_code: session_code, player_id: player_one.id)
        )

      assert page_title(game_view) =~ "Game ID: #{session_code} · Quiqup"

      {:ok, %{state: %{players: players}, player: player_two}} =
        Games.create_game(session_code, "Test Player 2")

      assert length(players) == 2

      {:ok, game_view_2, _html} =
        live(
          conn,
          Routes.game_game_path(conn, :new, session_code: session_code, player_id: player_two.id)
        )

      assert page_title(game_view_2) =~ "Game ID: #{session_code} · Quiqup"

      assert game_view
             |> element("div#turn")
             |> render() =~
               "<div id=\"turn\">\n\n      TURN: x\n\n          (My Turn)\n\n\n  </div>"

      assert game_view
             |> element("button#square-11")
             |> render_click() =~ "o"

      assert game_view
             |> element("div#turn")
             |> render() =~ "TURN: o"

      assert game_view_2
             |> element("div#turn")
             |> render() =~
               "<div id=\"turn\">\n\n      TURN: o\n\n          (My Turn)\n\n\n  </div>"

      assert game_view_2
             |> element("button#square-11")
             |> render_click() =~ "Square already taken by a player!"

      assert game_view_2
             |> element("button#square-12")
             |> render_click() =~ "x"

      assert game_view_2
             |> element("div#turn")
             |> render() =~ "TURN: x"
    end
  end
end
