defmodule EXCOM.Message.Notification do
  @moduledoc """
  Struct representing an MCP notification message.
  """

  defstruct method: nil, params: %{}

  @type t :: %__MODULE__{
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
