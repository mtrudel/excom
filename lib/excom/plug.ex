defmodule EXCOM.Plug do
  @moduledoc """
  A plug that exposes EXCOM's configured MCP primitives via HTTP streaming.
  """

  use Plug.Router

  plug(Plug.Parsers,
    parsers: [:json],
    pass: [],
    json_decoder: EXCOM.MessageParser,
    nest_all_json: true
  )

  plug(:find_or_create_session)
  plug(:match)
  plug(:dispatch)

  def find_or_create_session(conn, _opts) do
    case get_req_header(conn, "mcp-session-id") do
      [] ->
        put_private(conn, :excom_session, EXCOM.SessionStore.new())

      [session_id] ->
        case EXCOM.SessionStore.get(session_id) do
          {:ok, session} -> put_private(conn, :excom_session, session)
          {:error, :not_found} -> conn |> send_resp(404, "Session Not Found") |> halt()
        end
    end
  end

  get _ do
    send_resp(conn, 405, "")
  end

  post _ do
    conn
    |> put_resp_header("mcp-session-id", conn.private[:excom_session].id)
    |> send_resp(200, [])
  end

  delete _ do
    :ok = EXCOM.SessionStore.delete(conn.private[:excom_session])
    send_resp(conn, 204, "")
  end
end
