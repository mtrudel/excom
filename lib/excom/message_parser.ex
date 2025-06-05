defmodule EXCOM.MessageParser do
  @moduledoc """
  Parses JSON strings into MCP message structs.

  Implements the behaviour required by Plug.Parsers.JSON's json_decoder option
  """

  def decode!(json) when is_binary(json) do
    case Jason.decode!(json) do
      map when is_map(map) -> [to_struct!(map)]
      list when is_list(list) -> Enum.map(list, &to_struct!/1)
    end
  end

  defp to_struct!(%{"jsonrpc" => "2.0", "id" => id, "method" => method} = map) do
    %EXCOM.Message.Request{
      id: id,
      method: method,
      params: Map.get(map, "params", %{})
    }
  end

  defp to_struct!(%{"jsonrpc" => "2.0", "id" => id, "result" => result}) do
    %EXCOM.Message.Response{
      id: id,
      result: result
    }
  end

  defp to_struct!(%{"jsonrpc" => "2.0", "method" => method} = map) do
    %EXCOM.Message.Notification{
      method: method,
      params: Map.get(map, "params", %{})
    }
  end

  defp to_struct!(map) do
    raise "Invalid message format: #{inspect(map)}"
  end
end
