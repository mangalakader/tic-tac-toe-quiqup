defmodule TicTacToeQuiqup.GameSessionServerTest do
  @moduledoc """
  Unit Tests for Game Session Server Module
  """

  use TicTacToeQuiqup.DataCase, async: true

  alias TicTacToeQuiqup.{GamePlayer, GameSessionServer, GameSessionState, Utilities}

  setup do
    {:ok, px} = GamePlayer.new_x("Test Player 1")
    {:ok, po} = GamePlayer.new_x("Test Player 2")

    session_code = Utilities.generate_rand_str()

    game_server = start_supervised!({GameSessionServer, session_code: session_code, player: px})

    %{game_server: game_server, session_code: session_code, player_one: px, player_two: po}
  end

  describe "GameSessionServer - User Callbacks" do
    test "name/1 - via_tuple callback", %{session_code: session_code} do
      assert {:via, Registry, {TicTacToeQuiqup.Registry, new_session_code}} =
               GameSessionServer.name(session_code)

      assert new_session_code == session_code
    end

    test "state/1 - get current game server session state", %{session_code: session_code} do
      assert {:ok, %GameSessionState{} = state} = GameSessionServer.state(session_code)

      assert state.session_code == session_code
    end

    test "state/1 - game not found" do
      assert {:error, "Game not found!"} = GameSessionServer.state("RANDOM")
    end

    test "start_or_join/2 - start a new game", %{player_one: p1} do
      new_session_code = Utilities.generate_rand_str()

      assert {:ok, :started} = GameSessionServer.start_or_join(new_session_code, p1)
    end

    test "start_or_join/2 - join a game using old session code", %{
      session_code: session_code,
      player_one: p1
    } do
      assert {:ok, :joined} = GameSessionServer.start_or_join(session_code, p1)
    end

    test "start_or_join/2 - invalid player", %{
      session_code: session_code,
      player_one: p1,
      player_two: p2
    } do
      {:ok, invalid_player} = GamePlayer.new_x("INVALID PLAYER")
      assert {:ok, :joined} = GameSessionServer.start_or_join(session_code, p1)
      assert {:ok, :joined} = GameSessionServer.start_or_join(session_code, p2)
      assert {:error, _message} = GameSessionServer.start_or_join(session_code, invalid_player)
    end

    test "play/4 - capture location using session code", %{
      session_code: session_code,
      player_one: p1,
      player_two: p2
    } do
      assert {:ok, :joined} = GameSessionServer.start_or_join(session_code, p1)
      assert {:ok, :joined} = GameSessionServer.start_or_join(session_code, p2)

      assert {:ok, %GameSessionState{status: :playing, player_turn: :o}} =
               GameSessionServer.play(session_code, 1, 1, p1.id)

      assert {:ok, %GameSessionState{status: :playing, player_turn: :x}} =
               GameSessionServer.play(session_code, 1, 2, p2.id)

      assert {:error, "Player not found!"} = GameSessionServer.play(session_code, 1, 2, "RANDOM")
    end
  end

  describe "GameSessionServer - Testing GenServer Callbacks for user created scenarios" do
    test "ending a game by passing an info message", %{
      game_server: pid
    } do
      assert :end_game = send(pid, :end_game)
      Process.sleep(500)
      refute Process.alive?(pid)
    end
  end
end
