defmodule NeoFaker.MixProject do
  use Mix.Project

  def project do
    [
      app: :neo_faker,
      version: "0.10.0",
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
    "NeoFaker is an Elixir library that generates fake data for testing and development."
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/muzhawir/neo_faker"}
    ]
  end

  defp docs do
    [
      main: "getting-started",
      logo: "priv/assets/logo/doc_logo.svg",
      extras: extra_pages(),
      groups_for_modules: groups_for_modules()
    ]
  end

  defp extra_pages do
    List.flatten([
      Path.wildcard("lib/pages/**/*.md"),
      Path.wildcard("lib/pages/**/*.cheatmd")
    ])
  end

  defp groups_for_modules do
    [
      "Locale Random Generator": ~r/^NeoFaker\.[A-Z][a-z][A-Z][a-z]\..+/,
      "Random Generators": ~r/^NeoFaker/
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :mix]
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
