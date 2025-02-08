defmodule NeoFaker.MixProject do
  use Mix.Project

  def project do
    [
      app: :neo_faker,
      version: "0.4.3",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      name: "neo_faker",
      source_url: "https://github.com/muzhawir/neo_faker",
      homepage_url: "https://hex.pm/packages/neo_faker",
      docs: &docs/0
    ]
  end

  defp description do
    "Elixir package for generating fake data in tests and development"
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/muzhawir/neo_faker"}
    ]
  end

  defp docs do
    [
      main: "readme",
      logo: "./priv/logo/doc_logo.svg",
      extras: ["README.md"]
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
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},
      {:styler, "~> 1.2", only: [:dev, :test], runtime: false}
    ]
  end
end
