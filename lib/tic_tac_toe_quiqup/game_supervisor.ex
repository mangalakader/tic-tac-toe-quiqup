defmodule TicTacToeQuiqup.GameSupervisor do
  @moduledoc """
  DynamicSupervisor for TicTacToe Game
  """

  use DynamicSupervisor

  alias TicTacToeQuiqup.GameSessionServer

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def start_child(session_code, player) do
    spec = {GameSessionServer, session_code: session_code, player: player}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
