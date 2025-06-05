defmodule EXCOM.PlugTest do
  use ExUnit.Case, async: true

  use Machete

  setup do
    server_pid = start_supervised!({Bandit, plug: EXCOM.Plug, port: 0})
    {:ok, {_ip, port}} = ThousandIsland.listener_info(server_pid)
    [url: "http://localhost:#{port}", port: port, server_pid: server_pid]
  end

  describe "seesion identification" do
    test "request with no session header gets a session header in the response", context do
      resp = Req.post!(context.url, json: build_initialize())

      assert resp.status == 200
      assert resp.headers["mcp-session-id"] ~> [string(length: 22)]
    end

    test "request with existing session header gets a session header in the response", context do
      resp = Req.post!(context.url, json: build_initialize())
      [session_id] = resp.headers["mcp-session-id"]

      resp = Req.post!(context.url, json: [], headers: %{"Mcp-Session-Id": session_id})
      assert resp.status == 202
      assert resp.headers["mcp-session-id"] == [session_id]
    end

    test "can delete an existing session", context do
      resp = Req.post!(context.url, json: [])
      [session_id] = resp.headers["mcp-session-id"]

      resp = Req.delete!(context.url, headers: %{"Mcp-Session-Id": session_id})
      assert resp.status == 204
      assert is_nil(resp.headers["mcp-session-id"])
    end

    test "request with non-existent session header gets a 404 in response", context do
      resp = Req.post!(context.url, headers: %{"Mcp-Session-Id": "NON_EXISTENT_SESSION_ID"})
      assert resp.status == 404
    end
  end

  describe "seesion management" do
    test "happy path negotiation", context do
      resp = Req.post!(context.url, json: build_initialize())

      assert resp.status == 200
      assert resp.body ~> valid_initialize_response()
    end
  end

  defp build_initialize do
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

  defp build_request(id, method, params) do
    %{jsonrpc: "2.0", id: id, method: method}
    |> Map.merge(if map_size(params) > 0, do: %{params: params}, else: %{})
  end

  defp valid_initialize_response do
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

  defp valid_response(id, result) do
    %{"jsonrpc" => "2.0", "id" => id, "result" => result}
  end
end
