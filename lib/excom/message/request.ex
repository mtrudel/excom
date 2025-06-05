defmodule EXCOM.Message.Request do
  @moduledoc """
  Struct representing an MCP request message.
  """

  defstruct id: nil, method: nil, params: %{}

  @type t :: %__MODULE__{
          id: integer(),
          method: binary(),
          params: map()
        }

  defimpl Jason.Encoder do
    def encode(value, opts) do
      value
      |> Map.from_struct()
      |> Map.put(:jsonrpc, "2.0")
      |> Jason.Encode.map(opts)
    end
  end
end
