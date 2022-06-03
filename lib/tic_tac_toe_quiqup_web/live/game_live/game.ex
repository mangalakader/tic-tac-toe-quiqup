defmodule TicTacToeQuiqupWeb.GameLive.Game do
  use TicTacToeQuiqupWeb, :live_view

  alias Phoenix.PubSub
  alias TicTacToeQuiqup.{GameSessionServer, GameSessionState}

  @impl true
  def mount(
        %{"session_code" => session_code, "player_id" => player_id} = _params,
        _session,
        socket
      ) do
    if connected?(socket) do
      PubSub.subscribe(TicTacToeQuiqup.PubSub, "session:#{session_code}")
      send(self(), :load_game_session_state)
    end

    with {:ok, %GameSessionState{} = state} <- GameSessionServer.state(session_code),
         {:ok, player} <- GameSessionState.find_player(state, player_id) do
      {:ok,
       assign(socket,
         session_code: session_code,
         player_id: player_id,
         game_state: state,
         page_title: "Game ID: #{session_code}",
         player: player,
         name: session_code
       )}
    else
      {:error, reason} ->
        socket =
          socket
          |> assign(session_code: nil)
          |> put_flash(:error, reason)
          |> push_redirect(to: Routes.game_player_path(socket, :new))

        {:ok, socket}
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl true
  def handle_event(
        "play",
        %{"col" => col, "row" => row},
        %{assigns: %{session_code: session_code, player_id: player_id}} = socket
      ) do
    case GameSessionServer.play(
           session_code,
           String.to_integer(row),
           String.to_integer(col),
           player_id
         ) do
      {:ok, _state} ->
        {:noreply, socket}

      {:error, reason} ->
        {:noreply, put_flash(socket, :error, reason)}
    end
  end

  defp apply_action(socket, _action, _params) do
    socket
  end

  @impl true
  def handle_info(:load_game_session_state, %{assigns: %{session_code: code}} = socket) do
    Process.send_after(self(), :load_game_session_state, 5000)

    case GameSessionServer.state(code) do
      {:ok, %GameSessionState{} = state} ->
        {:ok, player} = GameSessionState.find_player(state, socket.assigns.player_id)
        {:noreply, assign(socket, game_state: state, player: player) |> clear_flash()}

      {:error, _reason} ->
        socket =
          socket
          |> assign(session_code: nil)
          |> put_flash(:error, "Game ended due to inactivity!")
          |> push_redirect(to: Routes.game_player_path(socket, :new))

        {:noreply, socket}
    end
  end

  @impl true
  def handle_info({:game_session_state, %GameSessionState{} = state} = _event, socket) do
    updated_socket =
      socket
      |> assign(:game_state, state)

    {:noreply, updated_socket}
  end
end
