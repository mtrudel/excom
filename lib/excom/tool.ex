defmodule EXCOM.Tool do
  @moduledoc """
  A behaviour for defining tools in the EXCOM framework.
  """

  @callback name() :: String.t()
  @callback description() :: String.t()
  @callback params() :: map()
  @callback run(map(), EXCOM.Session.t()) ::
              {:ok, map(), EXCOM.Session.t()} | {:error, String.t()}
end
