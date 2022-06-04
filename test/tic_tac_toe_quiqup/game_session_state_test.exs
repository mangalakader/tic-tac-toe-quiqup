defmodule TicTacToeQuiqup.GameSessionStateTest do
  @moduledoc """
  Unit Tests for Game Session State Module
  """

  use TicTacToeQuiqup.DataCase, async: true

  alias TicTacToeQuiqup.{GamePlayer, GameSessionState}

  setup do
    {:ok, player_one} = GamePlayer.new_x("Test Player 1")
    {:ok, player_two} = GamePlayer.new_o("Test Player 2")
    {_pid, ref} = spawn_monitor(fn -> :ok end)

    %{
      session_state: %GameSessionState{},
      player_one: player_one,
      player_two: player_two,
      ref: ref
    }
  end

  describe "event/1" do
    test "omit default argument - state" do
      assert {:error,
              %{reason: :invalid_game_state_transition, state: _state, action: :random_action}} =
               GameSessionState.event(:random_action)
    end
  end

  describe "event/2" do
    test "invalid action", %{session_state: state} do
      assert {:error,
              %{reason: :invalid_game_state_transition, state: _state, action: :random_action}} =
               GameSessionState.event(state, :random_action)
    end

    test "status game over", %{session_state: state} do
      assert {:error, "Game completed!"} =
               GameSessionState.event(%{state | status: :game_over}, :random_action)
    end
  end

  describe "event/2 - Joining Games" do
    test "a game with no players", %{session_state: state, player_one: player_one} do
      assert {:error, "Game not found!"} = GameSessionState.event(state, {:join_game, player_one})
    end

    test "completed game with 2 valid players", %{
      session_state: state,
      player_one: player_one,
      player_two: player_two
    } do
      assert {:error, "Game completed!"} =
               GameSessionState.event(
                 %{state | status: :game_over, players: [player_one, player_two]},
                 {:join_game, player_one}
               )
    end

    test "running game with 2 valid players", %{
      session_state: state,
      player_one: player_one,
      player_two: player_two
    } do
      assert {:error, "Game can be played only by maximum of 2 players"} =
               GameSessionState.event(
                 %{state | players: [player_one, player_two]},
                 {:join_game, player_one}
               )
    end

    test "running game with 1 valid players", %{
      session_state: state,
      player_one: player_one,
      player_two: player_two
    } do
      assert {:ok, %GameSessionState{players: [_player_one, _player_two], status: :playing}} =
               GameSessionState.event(
                 %{state | status: :playing, players: [player_one]},
                 {:join_game, player_two}
               )
    end

    test "same player one through different interface - running game with 1 valid players", %{
      session_state: state,
      player_one: player_one
    } do
      assert {:ok, %GameSessionState{players: [_player_one], status: :playing}} =
               GameSessionState.event(
                 %{state | status: :playing, players: [player_one]},
                 {:join_game, player_one}
               )
    end
  end

  describe "event/2 - Starting Games" do
    test "a new game", %{session_state: state, player_one: player_one} do
      assert {:ok,
              %GameSessionState{
                players: [_player_one],
                status: :playing,
                player_turn: :x,
                session_code: "RANDOM"
              }} = GameSessionState.event(state, {:start_game, "RANDOM", player_one})
    end

    test "a running game", %{session_state: state, player_one: player_one} do
      assert {:error, "Game has already started"} =
               GameSessionState.event(
                 %{state | status: :playing},
                 {:start_game, "RANDOM", player_one}
               )
    end
  end

  describe "event/2 - Playing Games" do
    test "running game - capturing a game square in the game board", %{
      session_state: state,
      player_one: player_one,
      player_two: player_two
    } do
      check_game_board = game_board(2, 3)

      assert {:ok,
              %GameSessionState{
                players: [_player_one, _player_two],
                status: :playing,
                player_turn: :o,
                session_code: "RANDOM",
                board: out_game_board
              }} =
               GameSessionState.event(
                 %{
                   state
                   | players: [player_one, player_two],
                     status: :playing,
                     player_turn: :x,
                     session_code: "RANDOM"
                 },
                 {:place, 2, 3, player_one.id}
               )

      assert check_game_board == out_game_board
    end

    test "running game - winner scenario", %{
      session_state: state,
      player_one: player_one,
      player_two: player_two
    } do
      check_game_board = winning_game_board()
      input_game_board = update_game_board(nil, 1, 3, check_game_board)

      assert {:ok,
              %GameSessionState{
                players: [_player_one, _player_two],
                status: :game_over,
                player_turn: nil,
                winner: :x,
                session_code: "RANDOM",
                board: out_game_board
              }} =
               GameSessionState.event(
                 %{
                   state
                   | players: [player_one, player_two],
                     status: :playing,
                     player_turn: :x,
                     board: input_game_board,
                     session_code: "RANDOM"
                 },
                 {:place, 1, 3, player_one.id}
               )

      assert check_game_board == out_game_board
    end

    test "running game - tie scenario", %{
      session_state: state,
      player_one: player_one,
      player_two: player_two
    } do
      check_game_board = tie_game_board()
      input_game_board = update_game_board(nil, 3, 1, check_game_board)

      assert {:ok,
              %GameSessionState{
                players: [_player_one, _player_two],
                status: :game_over,
                winner: nil,
                player_turn: nil,
                session_code: "RANDOM",
                board: out_game_board
              }} =
               GameSessionState.event(
                 %{
                   state
                   | players: [player_one, player_two],
                     status: :playing,
                     player_turn: :x,
                     board: input_game_board,
                     session_code: "RANDOM"
                 },
                 {:place, 3, 1, player_one.id}
               )

      assert check_game_board == out_game_board
    end

    test "running game - invalid player capturing a game square in the game board", %{
      session_state: state,
      player_one: player_one,
      player_two: player_two
    } do
      assert {:error, "Player not found!"} =
               GameSessionState.event(
                 %{
                   state
                   | players: [player_one, player_two],
                     status: :playing,
                     player_turn: :x,
                     session_code: "RANDOM"
                 },
                 {:place, 2, 3, "PLAYER-RANDOM"}
               )
    end

    test "running game with 1 valid player - capturing a game square in the game board", %{
      session_state: state,
      player_one: player_one
    } do
      assert {:error, "Waiting for player 2"} =
               GameSessionState.event(
                 %{
                   state
                   | players: [player_one],
                     status: :playing,
                     player_turn: :x,
                     session_code: "RANDOM"
                 },
                 {:place, 2, 3, player_one.id}
               )
    end
  end

  describe "reset_inactivity_time/1" do
    test "state has nil as inactivity_timer_ref", %{session_state: state} do
      assert %GameSessionState{inactivity_timer_ref: ref} =
               GameSessionState.reset_inactivity_time(state)

      assert is_reference(ref)
    end

    test "state has timer_reference as inactivity_timer_ref", %{session_state: state, ref: ref} do
      assert %GameSessionState{inactivity_timer_ref: ref_out} =
               GameSessionState.reset_inactivity_time(%{state | inactivity_timer_ref: ref})

      assert is_reference(ref_out)
      refute ref_out == ref
    end

    test "return :ok tuple - state has timer_reference as inactivity_timer_ref", %{
      session_state: state,
      ref: ref
    } do
      assert {:ok, %GameSessionState{inactivity_timer_ref: ref_out}} =
               GameSessionState.reset_inactivity_time({:ok, %{state | inactivity_timer_ref: ref}})

      assert is_reference(ref_out)
      refute ref_out == ref
    end
  end

  describe "find_player/2" do
    test "a player with given player id", %{session_state: state, player_one: p1, player_two: p2} do
      new_state = %{state | players: [p1, p2]}

      assert {:ok, %GamePlayer{} = player} = GameSessionState.find_player(new_state, p2.id)
      assert player.name == p2.name
      assert player.id == p2.id
      assert player.letter == p2.letter
    end

    test "error with unknown player id", %{session_state: state, player_one: p1, player_two: p2} do
      new_state = %{state | players: [p1, p2]}

      assert {:error, "Player not found!"} = GameSessionState.find_player(new_state, "RANDOM")
    end
  end

  describe "find_player/3" do
    test "a player with given player name", %{
      session_state: state,
      player_one: p1,
      player_two: p2
    } do
      new_state = %{state | players: [p1, p2]}

      assert {:ok, %GamePlayer{} = player} =
               GameSessionState.find_player(:name, new_state, p2.name)

      assert player.name == p2.name
      assert player.id == p2.id
      assert player.letter == p2.letter
    end

    test "error with unknown player name", %{session_state: state, player_one: p1, player_two: p2} do
      new_state = %{state | players: [p1, p2]}

      assert {:error, "Player not found!"} =
               GameSessionState.find_player(:name, new_state, "RANDOM")
    end
  end

  describe "player_letter/1" do
    test "determine player two letter with 1 valid player (:x) in game", %{
      session_state: state,
      player_one: p1
    } do
      new_state = %{state | players: [p1]}

      assert {:ok, :o} = GameSessionState.player_letter(new_state)
    end

    test "determine player two letter with 1 valid player (:o) in game", %{
      session_state: state,
      player_two: p2
    } do
      new_state = %{state | players: [p2]}

      assert {:ok, :x} = GameSessionState.player_letter(new_state)
    end

    test "determine player letter with no player in game", %{
      session_state: state
    } do
      assert {:ok, :x} = GameSessionState.player_letter(state)
    end

    test "error - determine player letter with 2 valid players in game", %{
      session_state: state,
      player_one: p1,
      player_two: p2
    } do
      assert {:error, "Game can be played only by maximum of 2 players"} =
               GameSessionState.player_letter(%{state | players: [p1, p2]})
    end
  end
end
