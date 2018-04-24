defmodule Schism.MixProject do
  use Mix.Project

  def project do
    [
      app: :schism,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: [
        main: "readme",
        extras: [
          "README.md"
        ]
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
      # only to generate tables for the docs
      {:benchee, "~> 0.13.0", only: [:dev]},
      {:ex_doc, "~> 0.18.3", only: [:dev]}
    ]
  end
end
