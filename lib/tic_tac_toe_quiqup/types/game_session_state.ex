defmodule TicTacToeQuiqup.Types.GameSessionState do
  @moduledoc """
  Type Specs for GameSessionState Module
  """

  alias TicTacToeQuiqup.Types.{GamePlayer, GameSquare}

  @type status() :: :not_started | :playing | :game_over

  @type gameplay_status() :: :continue | :tie | :winner

  @type join_game() :: {:join_game, GamePlayer.t() | any()}

  @type start_game() :: {:start_game, binary() | any(), GamePlayer.t() | any()}

  @type play_game() :: {:place, GameSquare.board_size(), GameSquare.board_size(), binary()}

  @type action() :: join_game() | start_game() | play_game()

  @type player_letters() :: :x | :o

  @type t() :: %TicTacToeQuiqup.GameSessionState{
          session_code: binary() | nil,
          status: status(),
          players: [] | [GamePlayer.t()],
          player_turn: player_letters() | nil,
          winner: player_letters() | nil,
          inactivity_timer_ref: reference(),
          board: Enumerable.t()
        }
end
