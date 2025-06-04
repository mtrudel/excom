defmodule EXCOM.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      EXCOM.SessionStore
    ]

    opts = [strategy: :one_for_one, name: EXCOM.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
