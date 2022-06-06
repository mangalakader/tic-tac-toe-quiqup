defmodule TicTacToeQuiqup.GameSessionServer do
  @moduledoc """
  A GenServer to manage different Game Sessions in the Server
  """

  @registry TicTacToeQuiqup.Registry

  require Logger

  alias Phoenix.PubSub
  alias TicTacToeQuiqup.{GamePlayer, GameSessionState}
  alias TicTacToeQuiqup.Types.Errors
  alias TicTacToeQuiqup.Types.GamePlayer, as: GamePlayerSpec
  alias TicTacToeQuiqup.Types.GameSessionState, as: GameSessionStateSpec

  use GenServer, restart: :transient

  @doc """
  The name function takes game session code as input and returns
  a tuple which can be used for calling genserver callbacks

    ```elixir
    iex> {:via, Registry, {TicTacToeQuiqup.Registry, "HELLO"}} =
    ...> TicTacToeQuiqup.GameSessionServer.name("HELLO")

    ```
  """
  @spec name(binary()) :: {atom(), atom(), {atom(), binary()}}
  def name(session_code), do: via_tuple(session_code)

  @doc """
  The state function takes game session code as input and returns
  the game state if a game session is found or returns a error

    ```elixir
    iex> {:ok, player} = TicTacToeQuiqup.GamePlayer.new_x("RANDOM")
    iex> {:ok, _pid} = TicTacToeQuiqup.GameSessionServer.start_link([session_code: "HELLO", player: player])
    iex> {:ok, %TicTacToeQuiqup.GameSessionState{session_code: "HELLO"}} =
    ...> TicTacToeQuiqup.GameSessionServer.state("HELLO")

    ```
  """
  @spec state(binary) :: {:ok, GameSessionStateSpec.t()} | Errors.t()
  def state(session_code) do
    if check_game?(session_code) do
      GenServer.call(via_tuple(session_code), :current_state)
    else
      {:error, "Game not found!"}
    end
  end

  @doc """
  The start_or_join function takes game session code and a player as input and returns
  the a :ok tuple or error tuple

    ```elixir
    iex> {:ok, player1} = TicTacToeQuiqup.GamePlayer.new_x("RANDOM133")
    iex> {:ok, player2} = TicTacToeQuiqup.GamePlayer.new_o("RANDOM233")
    iex> {:ok, player3} = TicTacToeQuiqup.GamePlayer.new_o("RANDOM333")
    iex> {:ok, :started} = TicTacToeQuiqup.GameSessionServer.start_or_join("HELLO2", player1)
    iex> {:ok, :joined} = TicTacToeQuiqup.GameSessionServer.start_or_join("HELLO2", player1)
    iex> {:ok, :joined} = 
    ...> TicTacToeQuiqup.GameSessionServer.start_or_join("HELLO2", player2)
    iex> {:error, "Game can be played only by maximum of 2 players"} = 
    ...> TicTacToeQuiqup.GameSessionServer.start_or_join("HELLO2", player3)

    ```
  """

  @spec start_or_join(binary(), GamePlayerSpec.t()) :: {:ok, :started | :joined} | Errors.t()
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
          {:ok, _state} -> {:ok, :joined}
          {:error, _reason} = error -> error
        end
    end
  end

  @doc """
  The join function takes game session code and a player as input and returns
  the a :ok tuple or error tuple

    ```elixir
    iex> {:ok, player1} = TicTacToeQuiqup.GamePlayer.new_x("RANDOM133")
    iex> {:ok, player2} = TicTacToeQuiqup.GamePlayer.new_o("RANDOM233")
    iex> {:ok, player3} = TicTacToeQuiqup.GamePlayer.new_o("RANDOM333")
    iex> {:ok, :started} = TicTacToeQuiqup.GameSessionServer.start_or_join("HELLO3", player1)
    iex> {:ok, %TicTacToeQuiqup.GameSessionState{players: [_p1, _p2]}} = 
    ...> TicTacToeQuiqup.GameSessionServer.join("HELLO3", player2)
    iex> {:error, "Game can be played only by maximum of 2 players"} = 
    ...> TicTacToeQuiqup.GameSessionServer.join("HELLO3", player3)

    ```
  """
  @spec join(binary(), GamePlayerSpec.t()) :: {:ok, GameSessionStateSpec.t()} | Errors.t()
  def join(session_code, player) do
    if check_game?(session_code) do
      GenServer.call(via_tuple(session_code), {:join_game, player})
    else
      {:error, "Game not found!"}
    end
  end

  @doc """
  The play function takes game session code, row, column and a player_id as input and returns
  the a :ok tuple or error tuple

    ```elixir
    iex> {:ok, player1} = TicTacToeQuiqup.GamePlayer.new_x("RANDOMX")
    iex> {:ok, player2} = TicTacToeQuiqup.GamePlayer.new_o("RANDOMO")
    iex> {:ok, :started} = TicTacToeQuiqup.GameSessionServer.start_or_join("HELLO4", player1)
    iex> {:error, "Waiting for player 2"} = 
    ...> TicTacToeQuiqup.GameSessionServer.play("HELLO4", 2, 2, player1.id)
    iex> {:ok, %TicTacToeQuiqup.GameSessionState{players: [_p1, _p2]}} = 
    ...> TicTacToeQuiqup.GameSessionServer.join("HELLO4", player2)
    iex> {:ok, %TicTacToeQuiqup.GameSessionState{
    ...>    board: %{
    ...>       %TicTacToeQuiqup.GameSquare{col: 2, row: 2} => :x
    ...>    }
    ...> }} = TicTacToeQuiqup.GameSessionServer.play("HELLO4", 2, 2, player1.id)

    ```
  """
  def play(session_code, row, col, player_id) do
    if check_game?(session_code) do
      GenServer.call(via_tuple(session_code), {:place, row, col, player_id})
    else
      {:error, "Game not found!"}
    end
  end

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

  @impl true
  def handle_call(:current_state, _from, %GameSessionState{} = state),
    do: {:reply, {:ok, state}, state}

  @impl true
  def handle_call(
        {:join_game, player} = event,
        _from,
        %GameSessionState{} = state
      ) do
    Logger.info("[Join Game] | #{state.session_code} | #{player.letter} joins!!!")

    case GameSessionState.event(state, event) do
      {:ok, new_state} -> {:reply, {:ok, new_state}, new_state}
      {:error, reason} -> {:reply, {:error, reason}, state}
    end
  end

  @impl true
  def handle_call({:place, row, col, player_id}, _from, %GameSessionState{} = state) do
    Logger.info("[Move] | #{state.session_code} | #{player_id} places in {#{row}, #{col}}")

    case GameSessionState.event(state, {:place, row, col, player_id}) do
      {:ok, new_state} ->
        broadcast_state(new_state)
        {:reply, {:ok, new_state}, new_state}

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

  @spec broadcast_state(GameSessionStateSpec.t()) :: :ok
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

  @spec via_tuple(binary()) :: {atom(), atom(), {atom(), binary()}}
  defp via_tuple(name), do: {:via, Registry, {@registry, name}}

  @spec check_game?(binary()) :: boolean()
  defp check_game?(session_code) do
    case Registry.lookup(@registry, session_code) do
      [{_pid, _any}] -> true
      [] -> false
    end
  end
end
