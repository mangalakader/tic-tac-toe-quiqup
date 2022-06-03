defmodule TicTacToeQuiqupWeb.GameLive.Player do
  use TicTacToeQuiqupWeb, :live_view

  alias TicTacToeQuiqup.{GamePlayer, GameSessionServer}

  @impl true
  def mount(_params, _session, socket),
    do: {:ok, assign(socket, session_code: nil, player_name: nil, letter: nil)}

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
            "player_name" => player_name,
            "letter" => letter
          }
        },
        socket
      ) do
    session_code =
      if session_code == "",
        do: TicTacToeQuiqup.Utilities.generate_game_session_code(),
        else: session_code

    with player_id <- TicTacToeQuiqup.Utilities.generate_game_session_code(12),
         new_player <- GamePlayer.new(player_id, player_name, letter),
         {:ok, _state} <-
           GameSessionServer.start_or_join(session_code, new_player) do
      socket =
        push_redirect(socket,
          to:
            Routes.game_game_path(socket, :new,
              session_code: session_code,
              player_id: player_id
            )
        )

      {:noreply, socket}
    else
      {:error, reason} ->
        {:noreply, put_flash(socket, :error, inspect(reason))}
    end
  end

  @impl true
  def handle_event(
        "validate",
        %{"player" => %{"session_code" => "", "player_name" => player_name, "letter" => letter}},
        socket
      ) do
    {:noreply, assign(socket, session_code: nil, player_name: player_name, letter: letter)}
  end

  @impl true
  def handle_event(
        "validate",
        %{
          "player" => %{
            "session_code" => session_code,
            "player_name" => player_name,
            "letter" => letter
          }
        },
        socket
      ) do
    {:noreply,
     assign(socket, session_code: session_code, player_name: player_name, letter: letter)}
  end

  defp apply_action(socket, _action, _params) do
    socket
  end
end
