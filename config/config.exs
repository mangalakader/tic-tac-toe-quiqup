# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :tic_tac_toe_quiqup,
  generators: [binary_id: true]

# Configures the endpoint
config :tic_tac_toe_quiqup, TicTacToeQuiqupWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: TicTacToeQuiqupWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: TicTacToeQuiqup.PubSub,
  live_view: [signing_salt: "pEkNwBbD"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.29",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Game is ended after 2 minutes of inactivity
config :tic_tac_toe_quiqup, TicTacToeQuiqup.GameSessionState, inactivity_timeout: 1000 * 60 * 2

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
