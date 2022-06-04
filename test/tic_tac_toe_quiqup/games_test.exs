defmodule TicTacToeQuiqup.GamesTest do
  @moduledoc """
  Unit Tests for Game Square Module
  """

  use TicTacToeQuiqup.DataCase, async: true

  alias TicTacToeQuiqup.{GamePlayer, Games, GameSessionState}

  setup do
    {:ok, game} = Games.create_game(nil, "Test Player 1")
    %{game: game}
  end

  describe "create_game/2" do
    test "create a new game using session code and player name" do
      assert {:ok,
              %{
                session_code: _session_code,
                state: %GameSessionState{status: :playing, players: [_p1]},
                player: %GamePlayer{name: "RANDOM", letter: :x}
              }} = Games.create_game(nil, "RANDOM")
    end

    test "join an old game using session code and existing player name", %{
      game: %{session_code: session_code, player: player}
    } do
      assert {:ok,
              %{
                session_code: new_session_code,
                state: %GameSessionState{status: :playing, players: [_p1]},
                player: %GamePlayer{name: "Test Player 1", letter: :x}
              }} = Games.create_game(session_code, player.name)

      assert session_code == new_session_code
    end

    test "join an old game using session code and new player", %{
      game: %{session_code: session_code}
    } do
      assert {:ok,
              %{
                session_code: new_session_code,
                state: %GameSessionState{status: :playing, players: [_p1, _p2]},
                player: %GamePlayer{name: "Test Player 2", letter: :o}
              }} = Games.create_game(session_code, "Test Player 2")

      assert session_code == new_session_code
    end
  end

  describe "get_game/1" do
    test "game state retrieval", %{game: %{session_code: session_code}} do
      assert {:ok,
              %{
                session_code: new_session_code,
                state: %GameSessionState{status: :playing, players: [_p1]}
              }} = Games.get_game(session_code)

      assert session_code == new_session_code
    end

    test "error for unknown session code" do
      assert {:error, "Game not found!"} = Games.get_game("TESTGAME")
    end
  end

  describe "move/4" do
    test "capture a location in the game board", %{
      game: %{session_code: session_code, player: player_one}
    } do
      check_game_board = game_board(1, 1)

      assert {:ok,
              %{
                session_code: _session_code,
                state: %GameSessionState{status: :playing, players: [_p1, _p2]},
                player: %GamePlayer{name: "Test Player 2", letter: :o}
              }} = Games.create_game(session_code, "Test Player 2")

      assert {:ok,
              %{
                session_code: new_session_code,
                state: %GameSessionState{status: :playing, players: [_p1, _p2], board: out_board}
              }} = Games.move(session_code, 1, 1, player_one.id)

      assert session_code == new_session_code
      assert check_game_board == out_board
    end

    test "error scenario - waiting for player 2", %{
      game: %{session_code: session_code, player: player}
    } do
      assert {:error, _message} = Games.move(session_code, 1, 1, player.id)
    end

    test "error scenario - square already captured", %{
      game: %{session_code: session_code, player: player}
    } do
      check_game_board = game_board(1, 1)

      assert {:ok,
              %{
                session_code: _session_code,
                state: %GameSessionState{status: :playing, players: [_p1, _p2]},
                player: %GamePlayer{name: "Test Player 2", letter: :o}
              }} = Games.create_game(session_code, "Test Player 2")

      assert {:ok,
              %{
                session_code: new_session_code,
                state: %GameSessionState{status: :playing, players: [_p1, _p2], board: out_board}
              }} = Games.move(session_code, 1, 1, player.id)

      assert session_code == new_session_code
      assert check_game_board == out_board

      assert {:error, "Square already taken by a player!"} =
               Games.move(session_code, 1, 1, player.id)
    end
  end
end
