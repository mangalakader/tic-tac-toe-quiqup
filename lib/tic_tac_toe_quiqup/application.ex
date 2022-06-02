defmodule TicTacToeQuiqup.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      TicTacToeQuiqupWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: TicTacToeQuiqup.PubSub},
      {Registry, name: TicTacToeQuiqup.Registry, keys: :unique},
      {TicTacToeQuiqup.GameSupervisor, []},
      # Start the Endpoint (http/https)
      TicTacToeQuiqupWeb.Endpoint
      # Start a worker by calling: TicTacToeQuiqup.Worker.start_link(arg)
      # {TicTacToeQuiqup.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TicTacToeQuiqup.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TicTacToeQuiqupWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
