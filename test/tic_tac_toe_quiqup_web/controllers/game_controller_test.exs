defmodule TicTacToeQuiqupWeb.GameControllerTest do
  use TicTacToeQuiqupWeb.ConnCase

  alias TicTacToeQuiqup.Games

  @create_attrs %{
    "player_name" => "Test Player 1",
    "session_code" => "TESTGAME"
  }

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create game" do
    @tag :api
    test "renders a new game when data is valid", %{conn: conn} do
      conn = post(conn, Routes.game_path(conn, :create), @create_attrs)
      assert %{"session_code" => session_code} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.game_path(conn, :show, session_code))

      assert %{
               "session_code" => ^session_code
             } = json_response(conn, 200)["data"]
    end

    @tag :api
    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.game_path(conn, :create), %{})
      assert json_response(conn, 400)["errors"] != %{}
    end

    @tag :api
    test "renders error when maximum players reached", %{conn: conn} do
      p1_conn =
        post(
          conn,
          Routes.game_path(conn, :create),
          %{"player_name" => "Test Player 1", "session_code" => ""}
        )

      assert %{"session_code" => session_code} = json_response(p1_conn, 201)["data"]

      p2_conn =
        post(
          conn,
          Routes.game_path(conn, :create),
          %{"player_name" => "Test Player 2", "session_code" => session_code}
        )

      assert %{"session_code" => _session_code} = json_response(p2_conn, 201)["data"]

      p3_conn =
        post(
          conn,
          Routes.game_path(conn, :create),
          %{"player_name" => "Test Player 3", "session_code" => session_code}
        )

      assert %{"details" => "Game can be played only by maximum of 2 players"} =
               json_response(p3_conn, 400)["errors"]
    end
  end

  describe "update game" do
    setup [:create_game]

    @tag :api
    test "renders game when data is valid", %{
      conn: conn,
      game: %{session_code: session_code, player: p1}
    } do
      {:ok, _new_game} = Games.create_game(session_code, "Test Player 2")

      attrs = %{
        "player_id" => p1.id,
        "row" => 1,
        "col" => 1,
        "id" => session_code
      }

      conn = put(conn, Routes.game_path(conn, :update, session_code), attrs)
      assert %{"session_code" => ^session_code} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.game_path(conn, :show, session_code))

      assert %{
               "session_code" => ^session_code
             } = json_response(conn, 200)["data"]
    end

    @tag :api
    test "renders errors when data is invalid", %{conn: conn, game: game} do
      conn = put(conn, Routes.game_path(conn, :update, game.session_code), %{})
      assert json_response(conn, 400)["errors"] != %{}
    end
  end

  describe "show game" do
    setup [:create_game]

    @tag :api
    test "show chosen game", %{conn: conn, game: %{session_code: session_code}} do
      conn = get(conn, Routes.game_path(conn, :show, session_code))

      assert %{
               "session_code" => ^session_code
             } = json_response(conn, 200)["data"]
    end

    @tag :api
    test "show error for non existent game", %{conn: conn} do
      conn = get(conn, Routes.game_path(conn, :show, "HELLO"))

      assert json_response(conn, 400)["errors"] == %{"details" => "Game not found!"}
    end
  end
end
