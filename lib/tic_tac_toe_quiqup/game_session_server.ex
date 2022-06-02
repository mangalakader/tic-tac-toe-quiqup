defmodule TicTacToeQuiqup.GameSessionServer do
  @moduledoc """
  A GenServer to manage different Game Sessions in the Server
  """

  alias TicTacToeQuiqup.GameSquare

  use GenServer

  @doc false
  def start_link, do: GenServer.start_link(__MODULE__, Map.new())

  @impl true
  def init(state), do: {:ok, state}

  def game_board,
    do:
      for(
        c <- 1..3,
        r <- 1..3,
        do: %GameSquare{col: c, row: r, occupied_by: nil}
      )
end
