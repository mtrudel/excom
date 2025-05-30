defmodule EXCOM.MixProject do
  use Mix.Project

  def project do
    [
      app: :excom,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_path(Mix.env()),
      name: "EXCOM",
      description: "EXCOM is an MCP server for Elixir",
      source_url: "https://github.com/mtrudel/excom",
      package: [
        maintainers: ["Mat Trudel"],
        licenses: ["MIT"],
        links: %{"GitHub" => "https://github.com/mtrudel/excom"},
        files: ["lib", "mix.exs", "README*", "LICENSE*", "CHANGELOG*"]
      ]
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:credo, ">= 0.0.0", only: [:dev, :test], runtime: false},
      {:dialyxir, ">= 0.0.0", only: [:dev, :test], runtime: false}
    ]
  end

  defp elixirc_path(:test), do: ["lib/", "test/support"]
  defp elixirc_path(_), do: ["lib/"]
end
