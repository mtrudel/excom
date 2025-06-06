defmodule EXCOM.Config do
  @moduledoc false

  defstruct tools: []

  def new do
    %__MODULE__{}
  end
end
