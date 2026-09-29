defmodule NeoFaker.App do
  @moduledoc """
  Functions for generating software application metadata.

  Covers the fields a package manifest or app store listing typically needs: names,
  authors, descriptions, licenses, semantic versions, bundle identifiers, and package
  names.
  """
  @moduledoc since: "0.4.0"

  alias NeoFaker.App.DomainGenerator
  alias NeoFaker.App.NameGenerator
  alias NeoFaker.App.SemverGenerator
  alias NeoFaker.App.Validator
  alias NeoFaker.Data
  alias NeoFaker.Helpers.Formatter
  alias NeoFaker.Locale
  alias NeoFaker.Person

  @description_file "description.exs"
  @license_file "license.exs"
  @name_file "name.exs"

  @name_styles [:camel_case, :pascal_case, :dashed, :underscore, :single]
  @semver_types [:pre_release, :build, :pre_release_build]

  @locale_schema NimbleOptions.new!(
                   locale: [type: {:custom, Locale, :validate_option, []}, default: nil]
                 )

  @name_schema NimbleOptions.new!(
                 style: [type: {:in, [nil | @name_styles]}, default: nil],
                 locale: [type: {:custom, Locale, :validate_option, []}, default: nil]
               )

  @semver_schema NimbleOptions.new!(type: [type: {:in, [nil | @semver_types]}, default: nil])

  @bundle_id_schema NimbleOptions.new!(
                      domain: [
                        type: {:custom, Validator, :validate_domain, []},
                        default: "example.com"
                      ],
                      style: [type: {:in, [:underscore, :dashed]}, default: :underscore]
                    )

  @package_name_schema NimbleOptions.new!(
                         domain: [
                           type: {:custom, Validator, :validate_domain, []},
                           default: "example.com"
                         ]
                       )

  @doc """
  Generates a random author name.

  Accepts the same options as `NeoFaker.Person.full_name/1`, except that `:middle_name`
  defaults to `false`, which reads more naturally in an author field.

  ## Options

    * `:middle_name` (boolean) - whether to include a middle name. Defaults to `false`.
    * `:sex` (`:unisex`, `:female`, or `:male`) - the sex of the name. Defaults to
      `:unisex`.
    * `:locale` (atom) - the locale to use. Defaults to the active locale, see
      `NeoFaker.Locale`.

  ## Examples

      iex> NeoFaker.App.author()
      "José Valim"

      iex> NeoFaker.App.author(middle_name: true)
      "Joshua Peter Bennet"

      iex> NeoFaker.App.author(sex: :female)
      "Juliana Silva"

  """
  @spec author(keyword()) :: String.t()
  def author(opts \\ []) do
    opts
    |> Keyword.put_new(:middle_name, false)
    |> Person.full_name()
  end

  @doc """
  Generates a random one-line app description.

  ## Options

    * `:locale` (atom) - the locale to use. Defaults to the active locale, see
      `NeoFaker.Locale`.

  ## Examples

      iex> NeoFaker.App.description()
      "Elixir library for generating fake data in tests and development."

      iex> NeoFaker.App.description(locale: :id_id)
      "Pustaka Elixir untuk menghasilkan data palsu dalam pengujian dan pengembangan."

  """
  @spec description(keyword()) :: String.t()
  def description(opts \\ []) do
    opts = NimbleOptions.validate!(opts, @locale_schema)
    Data.random_value(__MODULE__, @description_file, "descriptions", opts)
  end

  @doc """
  Generates a random open-source license name.

  Names come from the [choosealicense.com appendix](https://choosealicense.com/appendix),
  for example `"MIT License"` or `"Apache License 2.0"`.

  ## Examples

      iex> NeoFaker.App.license()
      "MIT License"

  """
  @spec license() :: String.t()
  def license, do: Data.random_value(__MODULE__, @license_file, "licenses")

  @doc """
  Generates a random two-word app name.

  ## Options

    * `:style` - the case style of the name. Defaults to `nil`.
      * `nil` - two capitalized words separated by a space, e.g. `"Neo Faker"`.
      * `:camel_case` - e.g. `"neoFaker"`.
      * `:pascal_case` - e.g. `"NeoFaker"`.
      * `:dashed` - lowercase words joined by a dash, e.g. `"neo-faker"`.
      * `:underscore` - lowercase words joined by an underscore, e.g. `"neo_faker"`.
      * `:single` - one of the two words, capitalized, e.g. `"Faker"`.
    * `:locale` (atom) - the locale to use. Defaults to the active locale, see
      `NeoFaker.Locale`.

  ## Examples

      iex> NeoFaker.App.name()
      "Neo Faker"

      iex> NeoFaker.App.name(style: :camel_case)
      "neoFaker"

      iex> NeoFaker.App.name(style: :dashed)
      "neo-faker"

      iex> NeoFaker.App.name(locale: :id_id)
      "Garuda Web"

  """
  @spec name(keyword()) :: String.t()
  def name(opts \\ []) do
    opts = NimbleOptions.validate!(opts, @name_schema)

    first = Data.random_value(__MODULE__, @name_file, "first_names", opts)
    last = Data.random_value(__MODULE__, @name_file, "last_names", opts)

    NameGenerator.format_text({first, last}, Keyword.fetch!(opts, :style))
  end

  @doc """
  Generates a random [semantic version](https://semver.org).

  ## Options

    * `:type` - which optional parts to append to `MAJOR.MINOR.PATCH`. Defaults to `nil`.
      * `nil` - the core version only, e.g. `"1.2.3"`.
      * `:pre_release` - a pre-release label, e.g. `"1.2.3-beta.1"`.
      * `:build` - build metadata, e.g. `"1.2.3+20250325"`.
      * `:pre_release_build` - both, e.g. `"1.2.3-rc.1+20250325"`.

  ## Examples

      iex> NeoFaker.App.semver()
      "1.2.3"

      iex> NeoFaker.App.semver(type: :pre_release)
      "1.2.3-beta.1"

      iex> NeoFaker.App.semver(type: :build)
      "1.2.3+20250325"

      iex> NeoFaker.App.semver(type: :pre_release_build)
      "1.2.3-rc.1+20250325"

  """
  @spec semver(keyword()) :: String.t()
  def semver(opts \\ []) do
    opts = NimbleOptions.validate!(opts, @semver_schema)
    core = SemverGenerator.core()

    case Keyword.fetch!(opts, :type) do
      nil -> core
      :pre_release -> "#{core}-#{SemverGenerator.pre_release()}"
      :build -> "#{core}+#{SemverGenerator.build()}"
      :pre_release_build -> "#{core}-#{SemverGenerator.pre_release()}+#{SemverGenerator.build()}"
    end
  end

  @doc """
  Generates a random `MAJOR.MINOR` version.

  ## Examples

      iex> NeoFaker.App.version()
      "1.2"

  """
  @spec version() :: String.t()
  def version, do: SemverGenerator.major_minor()

  @doc """
  Generates a random bundle identifier in reverse-domain notation.

  Bundle identifiers name apps on Apple platforms (`CFBundleIdentifier`) and are also
  common as Android application IDs. The last segment is a random app name from
  `name/1`.

  ## Options

    * `:domain` (string) - the organization's domain, reversed to form the prefix.
      Defaults to `"example.com"`.
    * `:style` (`:underscore` or `:dashed`) - how the words of the app name are joined.
      Defaults to `:underscore`.

  ## Examples

      iex> NeoFaker.App.bundle_id()
      "com.example.neo_faker"

      iex> NeoFaker.App.bundle_id(style: :dashed)
      "com.example.neo-faker"

      iex> NeoFaker.App.bundle_id(domain: "mycompany.io")
      "io.mycompany.neo_faker"

  """
  @spec bundle_id(keyword()) :: String.t()
  def bundle_id(opts \\ []) do
    opts = NimbleOptions.validate!(opts, @bundle_id_schema)
    prefix = DomainGenerator.reverse_domain!(Keyword.fetch!(opts, :domain))

    "#{prefix}.#{name(style: Keyword.fetch!(opts, :style))}"
  end

  @doc """
  Generates a random package name in Java reverse-domain notation.

  The last segment is a random app name, lowercased and stripped of every character that
  is not a letter or a digit, as Java package components require.

  ## Options

    * `:domain` (string) - the organization's domain, reversed to form the prefix.
      Defaults to `"example.com"`.

  ## Examples

      iex> NeoFaker.App.package_name()
      "com.example.neofaker"

      iex> NeoFaker.App.package_name(domain: "mycompany.id")
      "id.mycompany.neofaker"

  """
  @spec package_name(keyword()) :: String.t()
  def package_name(opts \\ []) do
    opts = NimbleOptions.validate!(opts, @package_name_schema)
    prefix = DomainGenerator.reverse_domain!(Keyword.fetch!(opts, :domain))

    "#{prefix}.#{Formatter.slugify(name())}"
  end
end
