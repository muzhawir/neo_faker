defmodule NeoFaker.Person do
  @moduledoc """
  Functions for generating person-related information.

  Provides utilities to generate random personal details including first, middle,
  and last names, full names, prefixes, suffixes, ages, and genders with support
  for multiple locales and sex options.
  """
  @moduledoc since: "0.6.0"

  alias NeoFaker.Data
  alias NeoFaker.Person.FullNameGenerator
  alias NeoFaker.Person.NameGenerator
  alias NeoFaker.Person.Validator

  @gender_file "gender.exs"
  @name_affixes_file "name_affixes.exs"

  @max_age 120

  @name_schema NimbleOptions.new!(
                 sex: [type: {:in, [:unisex, :male, :female]}, default: :unisex],
                 locale: [type: :atom, default: nil]
               )

  @full_name_schema NimbleOptions.new!(
                      sex: [type: {:in, [:unisex, :male, :female]}, default: :unisex],
                      locale: [type: :atom, default: nil],
                      middle_name: [type: :boolean, default: true]
                    )

  @locale_schema NimbleOptions.new!(locale: [type: :atom, default: nil])

  @gender_schema NimbleOptions.new!(
                   format: [
                     type: {:in, [:binary, :short_binary, :non_binary, :all]},
                     default: :binary
                   ],
                   locale: [type: :atom, default: nil]
                 )

  @full_name_with_title_schema NimbleOptions.new!(
                                 sex: [type: {:in, [:unisex, :male, :female]}, default: :unisex],
                                 locale: [type: :atom, default: nil],
                                 middle_name: [type: :boolean, default: true],
                                 prefix: [type: :boolean, default: false],
                                 suffix: [type: :boolean, default: false]
                               )

  @doc """
  Generates a random first name.

  ## Options

    * `:sex` (`:unisex`, `:female`, or `:male`) - the sex of the name. Defaults to `:unisex`.
    * `:locale` (atom) - the locale to use. Defaults to the application's configured locale.

  ## Examples

      iex> NeoFaker.Person.first_name()
      "Julia"

      iex> NeoFaker.Person.first_name(sex: :male)
      "José"

      iex> NeoFaker.Person.first_name(locale: :id_id)
      "Jaka"

  """
  @doc since: "0.7.0"
  @spec first_name(keyword()) :: String.t()
  def first_name(opts \\ []) do
    opts = NimbleOptions.validate!(opts, @name_schema)
    NameGenerator.name(Keyword.fetch!(opts, :locale), "first_names", Keyword.fetch!(opts, :sex))
  end

  @doc """
  Generates a random middle name.

  ## Options

    * `:sex` (`:unisex`, `:female`, or `:male`) - the sex of the name. Defaults to `:unisex`.
    * `:locale` (atom) - the locale to use. Defaults to the application's configured locale.

  ## Examples

      iex> NeoFaker.Person.middle_name()
      "Anne"

      iex> NeoFaker.Person.middle_name(sex: :male)
      "James"

      iex> NeoFaker.Person.middle_name(locale: :id_id)
      "Budi"

  """
  @doc since: "0.7.0"
  @spec middle_name(keyword()) :: String.t()
  def middle_name(opts \\ []) do
    opts = NimbleOptions.validate!(opts, @name_schema)
    NameGenerator.name(Keyword.fetch!(opts, :locale), "middle_names", Keyword.fetch!(opts, :sex))
  end

  @doc """
  Generates a random last name.

  ## Options

    * `:sex` (`:unisex`, `:female`, or `:male`) - the sex of the name. Defaults to `:unisex`.
    * `:locale` (atom) - the locale to use. Defaults to the application's configured locale.

  ## Examples

      iex> NeoFaker.Person.last_name()
      "Smith"

      iex> NeoFaker.Person.last_name(sex: :male)
      "Johnson"

      iex> NeoFaker.Person.last_name(locale: :id_id)
      "Wijaya"

  """
  @doc since: "0.7.0"
  @spec last_name(keyword()) :: String.t()
  def last_name(opts \\ []) do
    opts = NimbleOptions.validate!(opts, @name_schema)
    NameGenerator.name(Keyword.fetch!(opts, :locale), "last_names", Keyword.fetch!(opts, :sex))
  end

  @doc """
  Generates a random full name.

  Combines a first name, an optional middle name, and a last name.

  ## Options

    * `:sex` (`:unisex`, `:female`, or `:male`) - the sex of the name. Defaults to `:unisex`.
    * `:locale` (atom) - the locale to use. Defaults to the application's configured locale.
    * `:middle_name` (boolean) - whether to include a middle name. Defaults to `true`.

  ## Examples

      iex> NeoFaker.Person.full_name()
      "Abigail Bethany Crawford"

      iex> NeoFaker.Person.full_name(sex: :male)
      "Daniel Edward Fisher"

      iex> NeoFaker.Person.full_name(middle_name: false)
      "Gabriella Harrison"

      iex> NeoFaker.Person.full_name(sex: :female, locale: :id_id, middle_name: false)
      "Siti Nurhaliza"

  """
  @doc since: "0.7.0"
  @spec full_name(keyword()) :: String.t()
  def full_name(opts \\ []) do
    opts = NimbleOptions.validate!(opts, @full_name_schema)

    FullNameGenerator.name(
      Keyword.fetch!(opts, :sex),
      Keyword.fetch!(opts, :locale),
      Keyword.fetch!(opts, :middle_name)
    )
  end

  @doc """
  Generates a random name prefix such as `"Mr."`, `"Ms."`, or `"Dr."`.

  ## Options

    * `:locale` (atom) - the locale to use. Defaults to the application's configured locale.

  ## Examples

      iex> NeoFaker.Person.prefix()
      "Mr."

      iex> NeoFaker.Person.prefix(locale: :id_id)
      "Tn."

  """
  @doc since: "0.7.0"
  @spec prefix(keyword()) :: String.t()
  def prefix(opts \\ []) do
    opts = NimbleOptions.validate!(opts, @locale_schema)
    Data.random_value(__MODULE__, @name_affixes_file, "prefixes", opts)
  end

  @doc """
  Generates a random name suffix such as `"Jr."`, `"Sr."`, or `"III"`.

  ## Options

    * `:locale` (atom) - the locale to use. Defaults to the application's configured locale.

  ## Examples

      iex> NeoFaker.Person.suffix()
      "Jr."

      iex> NeoFaker.Person.suffix(locale: :id_id)
      "S.Kom"

      iex> NeoFaker.Person.suffix(locale: :en_us)
      "III"

  """
  @doc since: "0.7.0"
  @spec suffix(keyword()) :: String.t()
  def suffix(opts \\ []) do
    opts = NimbleOptions.validate!(opts, @locale_schema)
    Data.random_value(__MODULE__, @name_affixes_file, "suffixes", opts)
  end

  @doc """
  Generates a random gender value.

  ## Options

    * `:format` (`:binary`, `:short_binary`, `:non_binary`, or `:all`) - which gender
      representation to return. Defaults to `:binary`.
      * `:binary` - the full binary gender, e.g. `"Male"` or `"Female"`.
      * `:short_binary` - the abbreviated binary gender, e.g. `"M"` or `"F"`.
      * `:non_binary` - a non-binary gender identity string, e.g. `"Non-binary"`.
      * `:all` - the binary and non-binary identities combined, e.g. `"Female"` or
        `"Genderfluid"`. The abbreviated `:short_binary` codes are left out, since they are
        just shorthand for the binary values.
    * `:locale` (atom) - the locale to use. Defaults to the application's configured locale.

  ## Examples

      iex> NeoFaker.Person.gender()
      "Male"

      iex> NeoFaker.Person.gender(format: :short_binary)
      "M"

      iex> NeoFaker.Person.gender(format: :non_binary)
      "Non-binary"

      iex> NeoFaker.Person.gender(format: :all)
      "Genderfluid"

      iex> NeoFaker.Person.gender(locale: :id_id)
      "Perempuan"

  """
  @doc since: "0.15.0"
  @spec gender(keyword()) :: String.t()
  def gender(opts \\ []) do
    opts = NimbleOptions.validate!(opts, @gender_schema)
    format = Keyword.fetch!(opts, :format)
    locale_opts = Keyword.take(opts, [:locale])

    case format do
      :binary -> Data.random_value(__MODULE__, @gender_file, "binary", locale_opts)
      :short_binary -> Data.random_value(__MODULE__, @gender_file, "short_binary", locale_opts)
      :non_binary -> Data.random_value(__MODULE__, @gender_file, "non_binary", locale_opts)
      :all -> random_any_gender(locale_opts)
    end
  end

  # `:all` draws from the binary and non-binary identities pooled together. The
  # `short_binary` list is deliberately excluded: its entries ("M"/"F") are just
  # abbreviations of the binary values, not distinct identities.
  @spec random_any_gender(keyword()) :: String.t()
  defp random_any_gender(locale_opts) do
    %{"binary" => binary, "non_binary" => non_binary} =
      Data.fetch!(locale_opts[:locale], __MODULE__, @gender_file)

    Enum.random(binary ++ non_binary)
  end

  @doc """
  Generates a random age as a non-negative integer between `min` and `max`, inclusive.

  `min` defaults to `0` and `max` defaults to `120`.

  ## Examples

      iex> NeoFaker.Person.age()
      44

      iex> NeoFaker.Person.age(7, 44)
      27

      iex> NeoFaker.Person.age(18, 65)
      35

  """
  @spec age(non_neg_integer(), non_neg_integer()) :: non_neg_integer()
  def age(min \\ 0, max \\ @max_age) do
    Validator.validate_age_range!(min, max)

    Enum.random(min..max)
  end

  @doc """
  Generates a random full name with optional prefix and/or suffix.

  Delegates to `full_name/1` and wraps the result with the requested title parts.

  ## Options

    * `:sex` (`:unisex`, `:female`, or `:male`) - the sex of the name. Defaults to `:unisex`.
    * `:locale` (atom) - the locale to use. Defaults to the application's configured locale.
    * `:middle_name` (boolean) - whether to include a middle name. Defaults to `true`.
    * `:prefix` (boolean) - when `true`, prepends a name prefix such as `"Mr."` or `"Dr."`.
      Defaults to `false`.
    * `:suffix` (boolean) - when `true`, appends a name suffix such as `"Jr."` or `"III"`.
      Defaults to `false`.

  ## Examples

      iex> NeoFaker.Person.full_name_with_title(prefix: true)
      "Dr. Abigail Bethany Crawford"

      iex> NeoFaker.Person.full_name_with_title(suffix: true)
      "Daniel Edward Fisher Jr."

      iex> NeoFaker.Person.full_name_with_title(prefix: true, suffix: true, middle_name: false)
      "Mr. John Smith III"

  """
  @spec full_name_with_title(keyword()) :: String.t()
  def full_name_with_title(opts \\ []) do
    opts = NimbleOptions.validate!(opts, @full_name_with_title_schema)
    name_opts = Keyword.take(opts, [:sex, :locale, :middle_name])
    locale_opts = Keyword.take(opts, [:locale])

    [
      if(Keyword.fetch!(opts, :prefix), do: prefix(locale_opts)),
      full_name(name_opts),
      if(Keyword.fetch!(opts, :suffix), do: suffix(locale_opts))
    ]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
  end
end
