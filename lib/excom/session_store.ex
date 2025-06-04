defmodule EXCOM.SessionStore do
  @moduledoc """
  Models a store of Session state, accessible by ID.
  """

  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def new, do: GenServer.call(__MODULE__, :new)

  def get(id), do: GenServer.call(__MODULE__, {:get, id})

  def put(session), do: GenServer.call(__MODULE__, {:put, session})

  def delete(session), do: GenServer.call(__MODULE__, {:delete, session})

  @impl true
  def init(_args) do
    {:ok, %{}}
  end

  @impl true
  def handle_call(:new, _from, sessions) do
    session = EXCOM.Session.new()
    {:reply, session, Map.put(sessions, session.id, session)}
  end

  def handle_call({:get, id}, _from, sessions) do
    case Map.get(sessions, id) do
      nil -> {:reply, {:error, :not_found}, sessions}
      session -> {:reply, {:ok, session}, sessions}
    end
  end

  def handle_call({:put, session}, _from, sessions) do
    {:reply, :ok, Map.put(sessions, session.id, session)}
  end

  def handle_call({:delete, session}, _from, sessions) do
    {:reply, :ok, Map.delete(sessions, session.id)}
  end
end
