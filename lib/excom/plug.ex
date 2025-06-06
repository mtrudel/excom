defmodule EXCOM.Plug do
  @moduledoc """
  A plug that exposes EXCOM's configured MCP primitives via HTTP streaming.
  """

  use Plug.Router, copy_opts_to_assign: :excom_config

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
    config = conn.assigns[:excom_config]
    {messages, session} =
      conn.body_params["_json"]
      |> Enum.reduce({[], conn.private[:excom_session]}, fn message, {messages, session} ->
        {new_messages, session} = EXCOM.Server.handle_message(message, session, config)
        {[new_messages | messages], session}
      end)

    :ok = EXCOM.SessionStore.put(session)

    messages
    |> Enum.reverse()
    |> List.flatten()
    |> case do
      [] ->
        conn
        |> put_resp_header("mcp-session-id", conn.private[:excom_session].id)
        |> send_resp(202, "")

      [message] ->
        conn
        |> put_resp_content_type("application/json")
        |> put_resp_header("mcp-session-id", conn.private[:excom_session].id)
        |> send_resp(200, Jason.encode!(message))

      messages ->
        conn
        |> put_resp_content_type("application/json")
        |> put_resp_header("mcp-session-id", conn.private[:excom_session].id)
        |> send_resp(200, Jason.encode!(messages))
    end
  end

  delete _ do
    :ok = EXCOM.SessionStore.delete(conn.private[:excom_session])
    send_resp(conn, 204, "")
  end
end
