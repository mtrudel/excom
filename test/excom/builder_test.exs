defmodule EXCOM.BuilderTest do
  use ExUnit.Case, async: true

  use Machete

  import MCPClient

  defmodule MyTool do
    @behaviour EXCOM.Tool

    @impl true
    def name, do: "my_tool"

    @impl true
    def description, do: "A tool for testing purposes"

    @impl true
    def params, do: %{type: "object"}

    @impl true
    def run(params, session) do
      {:ok, %{result: inspect(params)}, session}
    end
  end

  defmodule MyBuilder do
    use EXCOM.Builder

    tool MyTool
  end

  setup do
    server_pid = start_supervised!({Bandit, plug: MyBuilder, port: 0})
    {:ok, {_ip, port}} = ThousandIsland.listener_info(server_pid)
    [url: "http://localhost:#{port}", port: port, server_pid: server_pid]
  end

  describe "tool listing" do
    test "defined tools are listed", context do
      session_id = negotiate_session(context.url)

      list_request = build_request(123, "tools/list", %{})
      resp = Req.post!(context.url, json: list_request, headers: %{"Mcp-Session-Id": session_id})
      assert resp.status == 200
      assert resp.body ~> valid_response(123, %{"tools" => [%{"name" => "my_tool", "description" => "A tool for testing purposes", "inputSchema" => %{"type" => "object"}}]})
    end
  end

  describe "tool execution" do
    test "tools can be executed", context do
      session_id = negotiate_session(context.url)

      call_request = build_request(123, "tools/call", %{name: "my_tool", arguments: %{}})
      resp = Req.post!(context.url, json: call_request, headers: %{"Mcp-Session-Id": session_id})
      assert resp.status == 200
      assert resp.body ~> valid_response(123, %{"result" => "%{}"})
    end
  end
end
