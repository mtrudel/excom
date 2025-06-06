defmodule EXCOM.Builder do
  @moduledoc """
  A module for defining MCP server behaviours.
  """

  defmacro __using__(_opts) do
    quote do
      import EXCOM.Builder, only: [tool: 1]

      @excom_config EXCOM.Config.new()
      @before_compile EXCOM.Builder

      # This needs to be after the EXCOM.Builder __before_compile__ since
      # it will be compiling the plug declaration made therein
      use Plug.Builder
    end
  end

  defmacro __before_compile__(env) do
    excom_config = Module.get_attribute(env.module, :excom_config)

    quote do
      plug EXCOM.Plug, unquote(Macro.escape(excom_config, unquote: true))
    end
  end

  defmacro tool(opts) do
    quote do
      @excom_config EXCOM.Config.handle_tool_declaration(@excom_config, unquote(opts))
    end
  end
end
