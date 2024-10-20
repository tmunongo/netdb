defmodule Netdb.Application do
  use Application

  def start(_type, _args) do
    children = [
      {Netdb, name: Netdb}
    ]

    opts = [strategy: :one_for_one, name: Netdb.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
