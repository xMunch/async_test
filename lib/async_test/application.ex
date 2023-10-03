defmodule AsyncTest.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      AsyncTestWeb.Telemetry,
      # Start the Ecto repository
      AsyncTest.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: AsyncTest.PubSub},
      # Start Finch
      {Finch, name: AsyncTest.Finch},
      # Start the Endpoint (http/https)
      AsyncTestWeb.Endpoint
      # Start a worker by calling: AsyncTest.Worker.start_link(arg)
      # {AsyncTest.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: AsyncTest.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    AsyncTestWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
