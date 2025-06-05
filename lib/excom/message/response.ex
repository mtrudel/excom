defmodule EXCOM.Message.Response do
  @moduledoc """
  Struct representing an MCP response message.
  """

  defstruct id: nil, result: %{}

  @type t :: %__MODULE__{
          id: integer(),
          result: map()
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
