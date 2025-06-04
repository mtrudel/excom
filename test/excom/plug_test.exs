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
      resp = Req.post!(context.url)

      assert resp.status == 200
      assert resp.headers["mcp-session-id"] ~> [string(length: 22)]
    end

    test "request with existing session header gets a session header in the response", context do
      resp = Req.post!(context.url)
      [session_id] = resp.headers["mcp-session-id"]

      resp = Req.post!(context.url, headers: %{"Mcp-Session-Id": session_id})
      assert resp.status == 200
      assert resp.headers["mcp-session-id"] == [session_id]
    end

    test "can delete an existing session", context do
      resp = Req.post!(context.url)
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
end
