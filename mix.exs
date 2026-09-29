defmodule NeoFaker.MixProject do
  use Mix.Project

  def project do
    [
      app: :neo_faker,
      version: "0.16.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      dialyzer: dialyzer(),
      # `mix test --cover` fails below this. CI runs it on the current toolchain.
      test_coverage: [summary: [threshold: 100]],
      description: description(),
      package: package(),
      deps: deps(),
      aliases: aliases(),
      name: "neo_faker",
      source_url: "https://github.com/muzhawir/neo_faker",
      homepage_url: "https://hex.pm/packages/neo_faker",
      docs: &docs/0
    ]
  end

  # Store the PLT under priv/plts so CI can cache it as a single directory.
  defp dialyzer do
    [
      plt_local_path: "priv/plts",
      plt_core_path: "priv/plts"
    ]
  end

  defp description do
    "Generates realistic fake data for Elixir tests, database seeds, and local development."
  end

  defp package do
    [
      files: ~w(lib priv/data priv/assets mix.exs README.md LICENSE.md .formatter.exs),
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/muzhawir/neo_faker",
        "Cheatsheet" => "https://hexdocs.pm/neo_faker/cheat.html",
        "Changelog" => "https://hexdocs.pm/neo_faker/changelog.html"
      }
    ]
  end

  defp docs do
    [
      main: "getting-started",
      logo: "priv/assets/logo/doc_logo.svg",
      extras: extra_pages(),
      groups_for_extras: groups_for_extras(),
      groups_for_modules: groups_for_modules(),
      # The changelog names functions and private modules as they were at each
      # release; many have since been renamed, removed, or hidden.
      skip_undefined_reference_warnings_on: ["lib/pages/about/changelog.md"]
    ]
  end

  # Listed explicitly (rather than globbed) so the sidebar order is intentional.
  defp extra_pages do
    [
      "lib/pages/guides/getting-started.md",
      "lib/pages/guides/locales.md",
      "lib/pages/guides/ecto-integration.md",
      "lib/pages/reference/cheat.cheatmd",
      "lib/pages/reference/locale-cheat.cheatmd",
      "lib/pages/contributing/adding-a-locale.md",
      "lib/pages/about/changelog.md"
    ]
  end

  defp groups_for_extras do
    [
      Guides: ~r{lib/pages/guides/},
      Reference: ~r{lib/pages/reference/},
      Contributing: ~r{lib/pages/contributing/},
      About: ~r{lib/pages/about/}
    ]
  end

  defp groups_for_modules do
    [
      "Random Generators": ~r/^NeoFaker(?!\.Locales\.)/,
      "Locale Random Generators": ~r/^NeoFaker\.Locales\..+/
    ]
  end

  # `mix docs` regenerates the cheatsheets first, so a docs build never
  # publishes stale ones. `mix docs.cheatsheet --check` only verifies them.
  defp aliases do
    [
      "docs.cheatsheet": "run scripts/gen_cheatsheet.exs",
      docs: ["docs.cheatsheet", "docs"]
    ]
  end

  def application, do: [extra_applications: [:logger]]

  defp deps do
    [
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.40.1", only: :dev, runtime: false},
      {:nimble_options, "~> 1.1"},
      {:styler, "~> 1.11", only: [:dev, :test], runtime: false}
    ]
  end
end
