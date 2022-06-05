defmodule TicTacToeQuiqup.Types.GamePlayer do
  @moduledoc """
  Type Specs for GamePlayer Module
  """

  @type letters() :: binary() | :x | :o | nil

  @type t() :: %TicTacToeQuiqup.GamePlayer{
          id: binary() | nil,
          name: binary() | nil,
          letter: letters()
        }
end
