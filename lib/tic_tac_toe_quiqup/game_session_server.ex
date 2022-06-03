defmodule TicTacToeQuiqup.GameSessionServer do
  @moduledoc """
  A GenServer to manage different Game Sessions in the Server
  """

  @registry TicTacToeQuiqup.Registry

  require Logger

  alias Phoenix.PubSub
  alias TicTacToeQuiqup.{GamePlayer, GameSessionState}

  use GenServer, restart: :transient

  @doc false
  def start_link([session_code: session_code, player: _player] = args) do
    case GenServer.start_link(
           __MODULE__,
           args,
           name: via_tuple(session_code)
         ) do
      {:ok, pid} -> {:ok, pid}
      {:error, {:already_started, _pid}} -> :already_started
    end
  end

  @impl true
  def init(session_code: session_code, player: player),
    do: GameSessionState.event({:start_game, session_code, player})

  def name(session_code), do: via_tuple(session_code)

  def state(session_code) do
    if check_game?(session_code) do
      GenServer.call(via_tuple(session_code), :current_state)
    else
      {:error, "Game not found!"}
    end
  end

  def start_or_join(session_code, %GamePlayer{} = player) do
    case DynamicSupervisor.start_child(
           TicTacToeQuiqup.GameSupervisor,
           {__MODULE__, [session_code: session_code, player: player]}
         ) do
      {:ok, _pid} ->
        Logger.info("[Start Game] | #{session_code} | #{player.letter} started a game!!!")
        {:ok, :started}

      {:error, :already_started} ->
        case join(session_code, player) do
          :ok -> {:ok, :joined}
          {:error, _reason} = error -> error
        end
    end
  end

  def join(session_code, player) do
    if check_game?(session_code) do
      GenServer.call(via_tuple(session_code), {:join_game, player})
    else
      {:error, "Game not found!"}
    end
  end

  def play(session_code, row, col, player_id) do
    if check_game?(session_code) do
      GenServer.call(via_tuple(session_code), {:place, row, col, player_id})
    else
      {:error, "Game not found!"}
    end
  end

  @impl true
  def handle_call(:current_state, _from, %GameSessionState{} = state), do: {:reply, state, state}

  def handle_call(
        {:join_game, player} = event,
        _from,
        %GameSessionState{} = state
      ) do
    Logger.info("[Join Game] | #{state.session_code} | #{player.letter} joins!!!")

    case GameSessionState.event(state, event) do
      {:ok, new_state} -> {:reply, :ok, new_state}
      {:error, reason} -> {:reply, {:error, reason}, state}
    end
  end

  def handle_call({:place, row, col, player_id}, _from, %GameSessionState{} = state) do
    Logger.info("[Move] | #{state.session_code} | #{player_id} places in {#{row}, #{col}}")

    case GameSessionState.event(state, {:place, row, col, player_id}) do
      {:ok, new_state} ->
        broadcast_state(new_state)
        {:reply, new_state, new_state}

      {:error, reason} ->
        broadcast_state(state)
        {:reply, {:error, reason}, state}
    end
  end

  @impl true
  def handle_info(:end_game, %GameSessionState{} = state) do
    Logger.info("[Inactivity] #{state.session_code} ended")
    {:stop, :normal, state}
  end

  defp broadcast_state(game_session_state) do
    Logger.info(
      "[Broadcast] #{game_session_state.session_code} | #{game_session_state.status} | Next Turn: #{game_session_state.player_turn} | Winner: #{game_session_state.winner}"
    )

    PubSub.broadcast(
      TicTacToeQuiqup.PubSub,
      "session:#{game_session_state.session_code}",
      {:game_session_state, game_session_state}
    )
  end

  defp via_tuple(name), do: {:via, Registry, {@registry, name}}

  defp check_game?(session_code) do
    case Registry.lookup(@registry, session_code) do
      [{_pid, _any}] -> true
      [] -> false
    end
  end
end
