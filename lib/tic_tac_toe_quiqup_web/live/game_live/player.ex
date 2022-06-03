defmodule TicTacToeQuiqupWeb.GameLive.Player do
  use TicTacToeQuiqupWeb, :live_view

  alias TicTacToeQuiqup.{GamePlayer, Games, GameSessionServer, GameSessionState}

  import TicTacToeQuiqup.Utilities, only: [check_game_session_code: 1]

  @impl true
  def mount(_params, _session, socket),
    do: {:ok, assign(socket, session_code: nil, player_name: nil)}

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl true
  def handle_event(
        "save",
        %{
          "player" => %{
            "session_code" => session_code,
            "player_name" => player_name
          }
        },
        socket
      ) do
    case Games.create_game(session_code, player_name) do
      {:ok, %{session_code: session_code, state: _state, player: player}} ->
        socket =
          push_redirect(socket,
            to:
              Routes.game_game_path(socket, :new,
                session_code: session_code,
                player_id: player.id
              )
          )

        {:noreply, socket}

      {:error, reason} ->
        {:noreply, put_flash(socket, :error, inspect(reason))}
    end
  end

  @impl true
  def handle_event(
        "validate",
        %{"player" => %{"session_code" => "", "player_name" => player_name}},
        socket
      ) do
    {:noreply, assign(socket, session_code: nil, player_name: player_name)}
  end

  @impl true
  def handle_event(
        "validate",
        %{
          "player" => %{
            "session_code" => session_code,
            "player_name" => player_name
          }
        },
        socket
      ) do
    {:noreply, assign(socket, session_code: session_code, player_name: player_name)}
  end

  def new_game(new_session_code, player_name) do
    with {:ok, new_player} <- GamePlayer.new_x(player_name),
         {:ok, _state} <-
           GameSessionServer.start_or_join(new_session_code, new_player) do
      {:ok, %{session_code: new_session_code, player: new_player}}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp apply_action(socket, _action, _params) do
    socket
  end
end
