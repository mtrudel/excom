defmodule EXCOM.Config do
  @moduledoc false

  defstruct tools: []

  def new do
    %__MODULE__{}
  end

  def handle_tool_declaration(config, tool_declaration) do
    %{config | tools: config.tools ++ [tool_declaration]}
  end
end
