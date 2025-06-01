defmodule MemorableIds.MixProject do
  use Mix.Project

  def project do
    [
      app: :memorable_ids,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      # Docs
      name: "Memorable IDs",
      source_url: "https://github.com/riipandi/memorable-ids-ex",
      homepage_url: "https://hexdocs.pm/memorable_ids",
      docs: &docs/0
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:castore, "~> 1.0"},
      {:excoveralls, "~> 0.18", only: [:test, :dev]},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false, warn_if_outdated: true}
    ]
  end

  defp docs do
    [
      # The main page in the docs
      main: "MemorableIds",
      # logo: "path/to/logo.png",
      extras: ["README.md"]
    ]
  end
end
