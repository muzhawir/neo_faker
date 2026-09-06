defmodule NeoFaker.MixProject do
  use Mix.Project

  def project do
    [
      app: :neo_faker,
      version: "0.15.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      dialyzer: dialyzer(),
      description: description(),
      package: package(),
      deps: deps(),
      name: "neo_faker",
      source_url: "https://github.com/muzhawir/neo_faker",
      homepage_url: "https://hex.pm/packages/neo_faker",
      docs: &docs/0
    ]
  end

  # Store the PLT under priv/plts so CI can cache it as a single directory.
  # `:mix` is added because application/0 lists it in :extra_applications.
  defp dialyzer do
    [
      plt_local_path: "priv/plts",
      plt_core_path: "priv/plts",
      plt_add_apps: [:mix]
    ]
  end

  defp description do
    "Fake data generator for Elixir tests and development environments."
  end

  defp package do
    [
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
      groups_for_modules: groups_for_modules()
    ]
  end

  # Listed explicitly (rather than globbed) so the sidebar order is intentional.
  # Each file lives under the lib/pages/ subfolder matching its group below.
  # ExDoc flattens every extra to `<basename>.html` regardless of subfolder, so
  # inter-page links stay `[text](getting-started.html)` and never reference the
  # folder.
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
      {:ex_doc, "~> 0.40.1", only: :dev, runtime: false},
      {:nimble_options, "~> 1.1"},
      {:styler, "~> 1.11", only: [:dev, :test], runtime: false}
    ]
  end
end
