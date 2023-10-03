defmodule AsyncTest.Repo do
  use Ecto.Repo,
    otp_app: :async_test,
    adapter: Ecto.Adapters.Postgres
end
