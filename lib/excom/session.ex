defmodule EXCOM.Session do
  @moduledoc """
  A module that abstracts MCP session state.
  """

  defstruct id: nil, state: :initializing, data: %{}

  @type t :: %__MODULE__{
          id: integer(),
          state: :initializing | :initialized,
          data: map()
        }

  def new do
    %__MODULE__{id: random_id()}
  end

  defp random_id do
    :crypto.strong_rand_bytes(16) |> Base.encode64(padding: false)
  end
end
