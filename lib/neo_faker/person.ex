defmodule NeoFaker.Person do
  @moduledoc """
  Functions for generating person-related information.

  Provides utilities to generate random personal details including first, middle,
  and last names, full names, prefixes, suffixes, ages, and genders with support
  for multiple locales and sex options.
  """
  @moduledoc since: "0.6.0"

  import NeoFaker.Data, only: [random_value: 4]

  alias NeoFaker.Helpers.Options
  alias NeoFaker.Person.FullNameGenerator
  alias NeoFaker.Person.NameGenerator
  alias NeoFaker.Person.Validator

  @gender_file "gender.exs"
  @name_affixes_file "name_affixes.exs"

  @locale :default
  @max_age 120

  @doc """
  Generates a random first name.

  ## Options

  - `:sex` - Sex of the name. One of `:unisex` (default), `:female`, or `:male`.
  - `:locale` - Locale to use. Defaults to the application's configured locale.

  ## Examples

      iex> NeoFaker.Person.first_name()
      "Julia"

      iex> NeoFaker.Person.first_name(sex: :male)
      "José"

      iex> NeoFaker.Person.first_name(locale: :id_id)
      "Jaka"

  """
  @doc since: "0.7.0"
  @spec first_name(Keyword.t()) :: String.t()
  def first_name(opts \\ []) do
    sex = Options.get(opts, :sex, :unisex)
    locale = Options.get(opts, :locale, @locale)

    Validator.validate_sex!(sex)

    NameGenerator.name(locale, "first_names", sex)
  end

  @doc """
  Generates a random middle name.

  ## Options

  - `:sex` - Sex of the name. One of `:unisex` (default), `:female`, or `:male`.
  - `:locale` - Locale to use. Defaults to the application's configured locale.

  ## Examples

      iex> NeoFaker.Person.middle_name()
      "Anne"

      iex> NeoFaker.Person.middle_name(sex: :male)
      "James"

      iex> NeoFaker.Person.middle_name(locale: :id_id)
      "Budi"

  """
  @doc since: "0.7.0"
  @spec middle_name(Keyword.t()) :: String.t()
  def middle_name(opts \\ []) do
    sex = Options.get(opts, :sex, :unisex)
    locale = Options.get(opts, :locale, @locale)

    Validator.validate_sex!(sex)

    NameGenerator.name(locale, "middle_names", sex)
  end

  @doc """
  Generates a random last name.

  ## Options

  - `:sex` - Sex of the name. One of `:unisex` (default), `:female`, or `:male`.
  - `:locale` - Locale to use. Defaults to the application's configured locale.

  ## Examples

      iex> NeoFaker.Person.last_name()
      "Smith"

      iex> NeoFaker.Person.last_name(sex: :male)
      "Johnson"

      iex> NeoFaker.Person.last_name(locale: :id_id)
      "Wijaya"

  """
  @doc since: "0.7.0"
  @spec last_name(Keyword.t()) :: String.t()
  def last_name(opts \\ []) do
    sex = Options.get(opts, :sex, :unisex)
    locale = Options.get(opts, :locale, @locale)

    Validator.validate_sex!(sex)

    NameGenerator.name(locale, "last_names", sex)
  end

  @doc """
  Generates a random full name.

  Combines a first name, an optional middle name, and a last name.

  ## Options

  - `:sex` - Sex of the name. One of `:unisex` (default), `:female`, or `:male`.
  - `:locale` - Locale to use. Defaults to the application's configured locale.
  - `:middle_name` - Whether to include a middle name. Defaults to `true`.

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
  @spec full_name(Keyword.t()) :: String.t()
  def full_name(opts \\ []) do
    sex = Options.get(opts, :sex, :unisex)
    locale = Options.get(opts, :locale, @locale)
    include_middle = Options.get(opts, :middle_name, true)

    Validator.validate_sex!(sex)

    FullNameGenerator.name(sex, locale, include_middle)
  end

  @doc """
  Generates a random name prefix such as `"Mr."`, `"Ms."`, or `"Dr."`.

  ## Options

  - `:locale` - Locale to use. Defaults to the application's configured locale.

  ## Examples

      iex> NeoFaker.Person.prefix()
      "Mr."

      iex> NeoFaker.Person.prefix(locale: :id_id)
      "Tn."

  """
  @doc since: "0.7.0"
  @spec prefix(Keyword.t()) :: String.t()
  def prefix(opts \\ []) do
    random_value(__MODULE__, @name_affixes_file, "prefixes", opts)
  end

  @doc """
  Generates a random name suffix such as `"Jr."`, `"Sr."`, or `"III"`.

  ## Options

  - `:locale` - Locale to use. Defaults to the application's configured locale.

  ## Examples

      iex> NeoFaker.Person.suffix()
      "Jr."

      iex> NeoFaker.Person.suffix(locale: :id_id)
      "S.Kom"

      iex> NeoFaker.Person.suffix(locale: :en_us)
      "III"

  """
  @doc since: "0.7.0"
  @spec suffix(Keyword.t()) :: String.t()
  def suffix(opts \\ []) do
    random_value(__MODULE__, @name_affixes_file, "suffixes", opts)
  end

  @doc """
  Generates a random binary gender.

  Returns either `"Male"` or `"Female"` in the configured locale.

  ## Options

  - `:locale` - Locale to use. Defaults to the application's configured locale.

  ## Examples

      iex> NeoFaker.Person.binary_gender()
      "Male"

      iex> NeoFaker.Person.binary_gender(locale: :id_id)
      "Perempuan"

  """
  @spec binary_gender(Keyword.t()) :: String.t()
  def binary_gender(opts \\ []) do
    random_value(__MODULE__, @gender_file, "binary", opts)
  end

  @doc """
  Generates a random short binary gender such as `"M"` or `"F"`.

  ## Options

  - `:locale` - Locale to use. Defaults to the application's configured locale.

  ## Examples

      iex> NeoFaker.Person.short_binary_gender()
      "M"

      iex> NeoFaker.Person.short_binary_gender(locale: :id_id)
      "P"

  """
  @spec short_binary_gender(Keyword.t()) :: String.t()
  def short_binary_gender(opts \\ []) do
    random_value(__MODULE__, @gender_file, "short_binary", opts)
  end

  @doc """
  Generates a random non-binary gender identity string.

  ## Options

  - `:locale` - Locale to use. Defaults to the application's configured locale.

  ## Examples

      iex> NeoFaker.Person.non_binary_gender()
      "Non-binary"

      iex> NeoFaker.Person.non_binary_gender(locale: :id_id)
      "Non-biner"

  """
  @spec non_binary_gender(Keyword.t()) :: String.t()
  def non_binary_gender(opts \\ []) do
    random_value(__MODULE__, @gender_file, "non_binary", opts)
  end

  @doc """
  Generates a random age as a non-negative integer.

  ## Parameters

  - `min` - Minimum age, inclusive. Defaults to `0`.
  - `max` - Maximum age, inclusive. Defaults to `120`.

  ## Examples

      iex> NeoFaker.Person.age()
      44

      iex> NeoFaker.Person.age(7, 44)
      27

      iex> NeoFaker.Person.age(18, 65)
      35

  """
  @spec age(non_neg_integer(), non_neg_integer()) :: non_neg_integer()
  def age(min \\ 0, max \\ @max_age)

  def age(min, max) when is_integer(min) and is_integer(max) do
    Validator.validate_age_range!(min, max)
    Enum.random(min..max)
  end

  def age(min, _max) when not is_integer(min) do
    raise ArgumentError, "min must be an integer, got: #{inspect(min)}"
  end

  def age(_min, max) when not is_integer(max) do
    raise ArgumentError, "max must be an integer, got: #{inspect(max)}"
  end

  @doc """
  Generates a random full name with optional prefix and/or suffix.

  Delegates to `full_name/1` and wraps the result with the requested title parts.

  ## Options

  - `:sex` - Sex of the name. One of `:unisex` (default), `:female`, or `:male`.
  - `:locale` - Locale to use. Defaults to the application's configured locale.
  - `:middle_name` - Whether to include a middle name. Defaults to `true`.
  - `:prefix` - When `true`, prepends a name prefix such as `"Mr."` or `"Dr."`. Defaults to `false`.
  - `:suffix` - When `true`, appends a name suffix such as `"Jr."` or `"III"`. Defaults to `false`.

  ## Examples

      iex> NeoFaker.Person.full_name_with_title(prefix: true)
      "Dr. Abigail Bethany Crawford"

      iex> NeoFaker.Person.full_name_with_title(suffix: true)
      "Daniel Edward Fisher Jr."

      iex> NeoFaker.Person.full_name_with_title(prefix: true, suffix: true, middle_name: false)
      "Mr. John Smith III"

  """
  @spec full_name_with_title(Keyword.t()) :: String.t()
  def full_name_with_title(opts \\ []) do
    include_prefix = Options.get(opts, :prefix, false)
    include_suffix = Options.get(opts, :suffix, false)

    [
      if(include_prefix, do: prefix(opts)),
      full_name(opts),
      if(include_suffix, do: suffix(opts))
    ]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
  end
end
