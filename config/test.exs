import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :tic_tac_toe_quiqup, TicTacToeQuiqupWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "gZ9VM4C2T4zkNQF+dTw027UJCud1yXYMOjLzXroGrtU34Pgr+d73qTXEWueDRW2u",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
