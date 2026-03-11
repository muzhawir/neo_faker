defmodule NeoFaker.Person do
  @moduledoc """
  Functions for generating person-related information.

  This module provides utilities to generate random personal details, such as names, ages,
  genders, and other person-specific data with support for multiple locales.
  """
  @moduledoc since: "0.6.0"

  import NeoFaker.Data, only: [random_value: 4]

  alias NeoFaker.Helpers.Constants
  alias NeoFaker.Helpers.Options
  alias NeoFaker.Person.FullNameGenerator
  alias NeoFaker.Person.NameGenerator

  @max_age 120

  @doc """
  Generates a random first name.

  Returns a random first name string. If no options are provided, it returns a random
  unisex first name by default.

  ## Parameters

  - `opts` - Keyword list of options:
    - `:sex` - Specifies the sex of the generated name. Defaults to `:unisex`.
    - `:locale` - Specifies the locale to use. Defaults to the application's current locale.

  ## Options

  Values for option `:sex` can be:

  - `:unisex` - Generates a random unisex name (default).
  - `:female` - Generates a random female name.
  - `:male` - Generates a random male name.

  Values for option `:locale` can be:

  - `nil` - Uses the default locale `:default`.
  - `:id_id` - Uses the Indonesian locale.
  - `:en_us` - Uses the US English locale.

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
    locale = Options.get(opts, :locale, Constants.default_locale())

    validate_sex!(sex)

    NameGenerator.name(locale, "first_names", sex)
  end

  @doc """
  Generates a random middle name.

  Returns a random middle name string. If no options are provided, it returns a random
  unisex middle name by default.

  ## Parameters

  - `opts` - Keyword list of options:
    - `:sex` - Specifies the sex of the generated name. Defaults to `:unisex`.
    - `:locale` - Specifies the locale to use. Defaults to the application's current locale.

  ## Options

  Values for option `:sex` can be:

  - `:unisex` - Generates a random unisex name (default).
  - `:female` - Generates a random female name.
  - `:male` - Generates a random male name.

  Values for option `:locale` can be:

  - `nil` - Uses the default locale `:default`.
  - `:id_id` - Uses the Indonesian locale.
  - `:en_us` - Uses the US English locale.

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
    locale = Options.get(opts, :locale, Constants.default_locale())

    validate_sex!(sex)

    NameGenerator.name(locale, "middle_names", sex)
  end

  @doc """
  Generates a random last name.

  Returns a random last name string. If no options are provided, it returns a random
  unisex last name by default.

  ## Parameters

  - `opts` - Keyword list of options:
    - `:sex` - Specifies the sex of the generated name. Defaults to `:unisex`.
    - `:locale` - Specifies the locale to use. Defaults to the application's current locale.

  ## Options

  Values for option `:sex` can be:

  - `:unisex` - Generates a random unisex name (default).
  - `:female` - Generates a random female name.
  - `:male` - Generates a random male name.

  Values for option `:locale` can be:

  - `nil` - Uses the default locale `:default`.
  - `:id_id` - Uses the Indonesian locale.
  - `:en_us` - Uses the US English locale.

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
    locale = Options.get(opts, :locale, Constants.default_locale())

    validate_sex!(sex)

    NameGenerator.name(locale, "last_names", sex)
  end

  @doc """
  Generates a random full name.

  Returns a full name string, which is a combination of a first name, an optional middle name, and
  a last name.

  ## Parameters

  - `opts` - Keyword list of options:
    - `:locale` - Specifies the locale to use. Defaults to the application's current locale.
    - `:sex` - Specifies the sex of the generated name. Defaults to `:unisex`.
    - `:middle_name` - Determines whether to include a middle name. Defaults to `true`.

  ## Options

  Values for option `:locale` can be:

  - `nil` - Uses the default locale `:default`.
  - `:id_id` - Uses the Indonesian locale.

  Values for option `:sex` can be:

  - `:unisex` - Generates a random unisex name (default).
  - `:male` - Generates a random male name.
  - `:female` - Generates a random female name.

  Values for option `:middle_name` can be:

  - `true` - Includes a random middle name (default).
  - `false` - Excludes the middle name.

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
    locale = Options.get(opts, :locale, Constants.default_locale())
    include_middle = Options.get(opts, :middle_name, true)

    validate_sex!(sex)

    FullNameGenerator.name(sex, locale, include_middle)
  end

  @doc """
  Generates a random name prefix.

  Returns a name prefix, such as `"Mr."`, `"Ms."`, `"Dr."`, etc.

  ## Parameters

  - `opts` - Keyword list of options:
    - `:locale` - Specifies the locale to use. Defaults to the application's current locale.

  ## Options

  Values for option `:locale` can be:

  - `nil` - Uses the default locale `:default`.
  - `:id_id` - Uses the Indonesian locale.
  - `:en_us` - Uses the US English locale.

  ## Examples

      iex> NeoFaker.Person.prefix()
      "Mr."

      iex> NeoFaker.Person.prefix(locale: :id_id)
      "Tn."

  """
  @spec prefix(Keyword.t()) :: String.t()
  def prefix(opts \\ []) do
    random_value(__MODULE__, Constants.name_affixes_file(), "prefixes", opts)
  end

  @doc """
  Generates a random name suffix.

  Returns a name suffix, such as `"Jr."`, `"Sr."`, `"III"`, etc.

  ## Parameters

  - `opts` - Keyword list of options:
    - `:locale` - Specifies the locale to use. Defaults to the application's current locale.

  ## Options

  Values for option `:locale` can be:

  - `nil` - Uses the default locale `:default`.
  - `:id_id` - Uses the Indonesian locale.
  - `:en_us` - Uses the US English locale.

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
    random_value(__MODULE__, Constants.name_affixes_file(), "suffixes", opts)
  end

  @doc """
  Generates a random binary gender.

  Returns either `"Male"` or `"Female"`.

  ## Parameters

  - `opts` - Keyword list of options:
    - `:locale` - Specifies the locale to use. Defaults to the application's current locale.

  ## Options

  Values for option `:locale` can be:

  - `nil` - Uses the default locale `:default`.
  - `:id_id` - Uses the Indonesian locale (returns "Laki-laki" or "Perempuan").

  ## Examples

      iex> NeoFaker.Person.binary_gender()
      "Male"

      iex> NeoFaker.Person.binary_gender(locale: :id_id)
      "Perempuan"

      iex> NeoFaker.Person.binary_gender(locale: :en_us)
      "Female"

  """
  @spec binary_gender(Keyword.t()) :: String.t()
  def binary_gender(opts \\ []) do
    random_value(__MODULE__, Constants.gender_file(), "binary", opts)
  end

  @doc """
  Generates a random short binary gender.

  Returns a short form of binary gender, such as `"M"` or `"F"`.

  ## Parameters

  - `opts` - Keyword list of options:
    - `:locale` - Specifies the locale to use. Defaults to the application's current locale.

  ## Options

  Values for option `:locale` can be:

  - `nil` - Uses the default locale `:default`.
  - `:id_id` - Uses the Indonesian locale (returns "L" or "P").

  ## Examples

      iex> NeoFaker.Person.short_binary_gender()
      "M"

      iex> NeoFaker.Person.short_binary_gender(locale: :id_id)
      "P"

  """
  @spec short_binary_gender(Keyword.t()) :: String.t()
  def short_binary_gender(opts \\ []) do
    random_value(__MODULE__, Constants.gender_file(), "short_binary", opts)
  end

  @doc """
  Generates a random non-binary gender.

  Returns a non-binary gender identity string.

  ## Parameters

  - `opts` - Keyword list of options:
    - `:locale` - Specifies the locale to use. Defaults to the application's current locale.

  ## Options

  Values for option `:locale` can be:

  - `nil` - Uses the default locale `:default`.
  - `:id_id` - Uses the Indonesian locale.

  ## Examples

      iex> NeoFaker.Person.non_binary_gender()
      "Non-binary"

      iex> NeoFaker.Person.non_binary_gender(locale: :id_id)
      "Non-biner"

  """
  @spec non_binary_gender(Keyword.t()) :: String.t()
  def non_binary_gender(opts \\ []) do
    random_value(__MODULE__, Constants.gender_file(), "non_binary", opts)
  end

  @doc """
  Generates a random age.

  Returns an age as a non-negative integer between `min` and `max`. By default, generates
  an age between `0` and `120`.

  ## Parameters

  - `min` - The minimum age (inclusive). Defaults to `0`.
  - `max` - The maximum age (inclusive). Defaults to `120`.

  ## Examples

      iex> NeoFaker.Person.age()
      44

      iex> NeoFaker.Person.age(7, 44)
      27

      iex> NeoFaker.Person.age(18, 65)
      35

      iex> NeoFaker.Person.age(0, 10)
      5

  """
  @spec age(non_neg_integer(), non_neg_integer()) :: non_neg_integer()
  def age(min \\ 0, max \\ @max_age)

  def age(min, max) when is_integer(min) and is_integer(max) do
    validate_age_range!(min, max)
    Enum.random(min..max)
  end

  def age(min, _max) when not is_integer(min) do
    raise ArgumentError, "min must be an integer, got: #{inspect(min)}"
  end

  def age(_min, max) when not is_integer(max) do
    raise ArgumentError, "max must be an integer, got: #{inspect(max)}"
  end

  @doc """
  Generates a random full name with prefix and/or suffix.

  Returns a full name with optional title prefix and/or name suffix.

  ## Parameters

  - `opts` - Keyword list of options:
    - `:sex` - Specifies the sex of the generated name. Defaults to `:unisex`.
    - `:locale` - Specifies the locale to use. Defaults to the application's current locale.
    - `:middle_name` - Include middle name. Defaults to `true`.
    - `:prefix` - Include name prefix (e.g., "Mr.", "Dr."). Defaults to `false`.
    - `:suffix` - Include name suffix (e.g., "Jr.", "III"). Defaults to `false`.

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

    name_parts = []

    name_parts =
      if include_prefix do
        [prefix(opts) | name_parts]
      else
        name_parts
      end

    name_parts = [full_name(opts) | name_parts]

    name_parts =
      if include_suffix do
        name_parts ++ [suffix(opts)]
      else
        name_parts
      end

    name_parts |> Enum.reverse() |> Enum.join(" ")
  end

  # Private functions

  @spec validate_sex!(atom()) :: :ok
  defp validate_sex!(sex) do
    valid_sex_options = Constants.valid_sex_options()

    case Options.validate_enum(:sex, sex, valid_sex_options) do
      :ok ->
        :ok

      {:error, reason} ->
        raise ArgumentError, reason
    end
  end

  @spec validate_age_range!(non_neg_integer(), non_neg_integer()) :: :ok
  defp validate_age_range!(min, max) when is_integer(min) and is_integer(max) do
    cond do
      min < 0 ->
        raise ArgumentError, "min must be non-negative, got: #{min}"

      max < 0 ->
        raise ArgumentError, "max must be non-negative, got: #{max}"

      min > max ->
        raise ArgumentError, "min must be less than or equal to max"

      true ->
        :ok
    end
  end
end
