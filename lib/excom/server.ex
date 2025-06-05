defmodule EXCOM.Server do
  @moduledoc false

  alias Mint.HTTP1.Response
  alias EXCOM.Message.{Notification, Request, Response}

  # Initialization

  def handle_message(
        %Request{method: "initialize", params: %{"protocolVersion" => "2025-03-26"}} = message,
        %EXCOM.Session{state: :initializing} = session
      ) do
    result = %{
      protocolVersion: "2025-03-26",
      capabilities: %{
        tools: %{}
      },
      serverInfo: %{
        name: "EXCOM",
        version: to_string(Application.spec(:excom)[:vsn])
      }
    }

    {%Response{id: message.id, result: result}, session}
  end

  def handle_message(
        %Notification{method: "notifications/initialized"},
        %EXCOM.Session{state: :initializing} = session
      ) do
    {[], %{session | state: :initialized}}
  end

  # Ping

  def handle_message(%Request{method: "ping"} = message, %EXCOM.Session{} = session) do
    {%Response{id: message.id}, session}
  end

  def handle_message(%Response{}, %EXCOM.Session{} = session), do: {[], session}
  def handle_message(%Notification{}, %EXCOM.Session{} = session), do: {[], session}
end
