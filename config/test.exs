use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :cinema_api, CinemaApiWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :cinema_api, CinemaApi.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "tahmid",
  password: "",
  database: "cinema_api_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
