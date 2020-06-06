defmodule Cospex.MixProject do
  use Mix.Project

  def project do
    [
      app: :cospex,
      licenses: ["MPL-2.0"],
      source_url: "https://github.com/braunse/cospex",
      homepage_url: "https://github.com/braunse/cospex",
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.html": :test
      ]
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
      {:plug, "~> 1.10.1"},
      {:phoenix, "~> 1.5.3"},
      {:phoenix_html, "~> 2.14.2"},

      {:credo, "~> 1.4.0", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0.0", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.22.1", only: :dev, runtime: false},
      {:excoveralls, "~> 0.13.0", only: :test}
    ]
  end
end
