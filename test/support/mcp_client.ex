defmodule MCPClient do
  @moduledoc """
  Minimal MCP client using the 2025-03-26 HTTP Streaming protocol
  """

  use Machete

  def negotiate_session(url) do
    resp = Req.post!(url, json: build_initialize())
    [session_id] = resp.headers["mcp-session-id"]
    assert resp.status == 200
    resp = Req.post!(url, json: build_initialized_notification(), headers: %{"Mcp-Session-Id": session_id})
    assert resp.status == 202
    session_id
  end

  def build_initialize do
    build_request(
      1,
      "initialize",
      %{
        protocolVersion: "2025-03-26",
        capabilities: %{roots: %{listChanged: true}, sampling: %{}},
        clientInfo: %{name: "ExampleClient", version: "1.0.0"}
      }
    )
  end

  def build_request(id, method, params) do
    %{jsonrpc: "2.0", id: id, method: method}
    |> Map.merge(if map_size(params) > 0, do: %{params: params}, else: %{})
  end

  def build_initialized_notification do
    build_notification("notifications/initialized", %{})
  end

  def build_notification(method, params) do
    %{jsonrpc: "2.0", method: method}
    |> Map.merge(if map_size(params) > 0, do: %{params: params}, else: %{})
  end

  @doc """
  Returns a Machete matcher for a valid initialize response
  """
  def valid_initialize_response do
    valid_response(
      1,
      %{
        "protocolVersion" => "2025-03-26",
        "capabilities" => %{
          "tools" => %{}
        },
        "serverInfo" => %{
          "name" => "EXCOM",
          "version" => to_string(Application.spec(:excom)[:vsn])
        }
      }
    )
  end

  @doc """
  Returns a Machete matcher for a valid response
  """
  def valid_response(id, result) do
    %{"jsonrpc" => "2.0", "id" => id, "result" => result}
  end
end
