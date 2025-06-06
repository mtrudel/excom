defmodule EXCOM.Server do
  @moduledoc false

  alias Mint.HTTP1.Response
  alias EXCOM.Message.{Notification, Request, Response}

  # Initialization

  def handle_message(
        %Request{method: "initialize", params: %{"protocolVersion" => "2025-03-26"}} = message,
        %EXCOM.Session{state: :initializing} = session,
        _config
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
        %EXCOM.Session{state: :initializing} = session,
        _config
      ) do
    {[], %{session | state: :initialized}}
  end

  # Ping

  def handle_message(%Request{method: "ping"} = message, %EXCOM.Session{} = session, _config) do
    {%Response{id: message.id}, session}
  end

  # Tool listing

  def handle_message(
        %Request{method: "tools/list"} = message,
        %EXCOM.Session{state: :initialized} = session,
        %EXCOM.Config{} = config
      ) do
    result = %{
      tools:
        config.tools
        |> Enum.map(&%{name: &1.name(), description: &1.description(), inputSchema: &1.params()})
    }

    {%Response{id: message.id, result: result}, session}
  end

  # Tool execution

  def handle_message(
        %Request{method: "tools/call", params: %{"name" => tool_name, "arguments" => args}} =
          message,
        %EXCOM.Session{state: :initialized} = session,
        %EXCOM.Config{} = config
      ) do
    case Enum.find(config.tools, &(&1.name() == tool_name)) do
      tool when not is_nil(tool) ->
        case tool.run(args, session) do
          {:ok, result, session} ->
            {%Response{id: message.id, result: result}, session}
            # TBD error
        end

        # TBD no tool founds
    end
  end

  def handle_message(%Response{}, %EXCOM.Session{} = session, _config), do: {[], session}
  def handle_message(%Notification{}, %EXCOM.Session{} = session, _config), do: {[], session}
end
