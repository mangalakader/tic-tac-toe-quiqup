defmodule TicTacToeQuiqupWeb.GameLive.Player do
  use TicTacToeQuiqupWeb, :live_view

  alias TicTacToeQuiqup.Games

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
                player_id: player.id,
                session_code: session_code
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

  defp apply_action(socket, _action, _params), do: socket
end
