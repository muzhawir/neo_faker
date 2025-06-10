defmodule NeoFaker.Person do
  @moduledoc """
  Functions for generating person-related information.

  This module provides utilities to generate random personal details, such as names, ages, and
  genders.
  """
  @moduledoc since: "0.6.0"

  import NeoFaker.Data.Generator, only: [random_value: 4]
  import NeoFaker.Person.FullName
  import NeoFaker.Person.Name

  @gender_file "gender.exs"
  @name_affixes_file "name_affixes.exs"

  @doc """
  Generates a random first name.

  Returns a random first name string. If no options are provided, it returns a random
  unisex first name by default.

  ## Options

  The accepted options are:

  - `:sex` - Specifies the sex of the generated name.
  - `:locale` - Specifies the locale to use.

  Values for option `:sex` can be:

  - `:unisex` - Generates a random unisex name (default).
  - `:female` - Generates a random female name.
  - `:male` - Generates a random male name.

  Values for option `:locale` can be:

  - `nil` - Uses the default locale `:default`.
  - `:id_id` - Uses the Indonesian locale, for example.

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
    generate_random_name(
      Keyword.get(opts, :locale, :default),
      "first_names",
      Keyword.get(opts, :sex, :unisex)
    )
  end

  @doc """
  Generates a random middle name.

  This function behaves the same way as `first_name/1`, but it generates a middle name instead.
  """
  @doc since: "0.7.0"
  @spec middle_name(Keyword.t()) :: String.t()
  def middle_name(opts \\ []) do
    generate_random_name(
      Keyword.get(opts, :locale, :default),
      "middle_names",
      Keyword.get(opts, :sex, :unisex)
    )
  end

  @doc """
  Generates a random last name.

  This function behaves the same way as `first_name/1`, but it generates a last name instead.
  """
  @doc since: "0.7.0"
  @spec last_name(Keyword.t()) :: String.t()
  def last_name(opts \\ []) do
    generate_random_name(
      Keyword.get(opts, :locale, :default),
      "last_names",
      Keyword.get(opts, :sex, :unisex)
    )
  end

  @doc """
  Generates a random full name.

  Returns a full name string, which is a combination of a first name, an optional middle name, and
  a last name.

  ## Options

  The accepted options are:

  - `:locale` - Specifies the locale to use.
  - `:sex` - Specifies the sex of the generated name.
  - `:middle_name` - Determines whether to include a middle name in the full name.

  Values for option `:locale` can be:

  - `nil` - Uses the default locale `:default`.
  - `:id_id` - Uses the Indonesian locale, for example.

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

  """
  @doc since: "0.7.0"
  @spec full_name(Keyword.t()) :: String.t()
  def full_name(opts \\ []) do
    generate_random_full_name(
      Keyword.get(opts, :sex, :unisex),
      Keyword.get(opts, :locale, :default),
      Keyword.get(opts, :middle_name, true)
    )
  end

  @doc """
  Generates a random name prefix.

  Returns a name prefix, such as `"Mr."`, `"Ms."`, `"Dr."`, etc.

  ## Options

  The accepted options are:

  - `:locale` - Specifies the locale to use.

  Values for option `:locale` can be:

  - `nil` - Uses the default locale `:default`.
  - `:id_id` - Uses the Indonesian locale, for example.

  ## Examples

      iex> NeoFaker.Person.prefix()
      "Mr."

      iex> NeoFaker.Person.prefix(locale: :id_id)
      "Tn."

  """
  @spec prefix(Keyword.t()) :: String.t()
  def prefix(opts \\ []), do: random_value(__MODULE__, @name_affixes_file, "prefixes", opts)

  @doc """
  Generates a random name suffix.

  This function behaves the same way as `prefix/1`, but it generates a name suffix instead.
  """
  @doc since: "0.7.0"
  @spec suffix(Keyword.t()) :: String.t()
  def suffix(opts \\ []), do: random_value(__MODULE__, @name_affixes_file, "suffixes", opts)

  @doc """
  Generates a random binary gender.

  Returns either `"Male"` or `"Female"`.

  ## Options

  The accepted options are:

  - `:locale` - Specifies the locale to use.

  Values for option `:locale` can be:

  - `nil` - Uses the default locale `:default`.
  - `:id_id` - Uses the Indonesian locale, for example.

  ## Examples

      iex> NeoFaker.Person.binary_gender()
      "Male"

      iex> NeoFaker.Person.binary_gender(locale: :id_id)
      "Perempuan"

  """
  @spec binary_gender(Keyword.t()) :: String.t()
  def binary_gender(opts \\ []), do: random_value(__MODULE__, @gender_file, "binary", opts)

  @doc """
  Generates a random short binary gender.

  This function behaves the same way as `binary_gender/1`, but it returns a shorter version
  instead.
  """
  @spec short_binary_gender(Keyword.t()) :: String.t()
  def short_binary_gender(opts \\ []) do
    random_value(__MODULE__, @gender_file, "short_binary", opts)
  end

  @doc """
  Generates a random non-binary gender.

  This function behaves the same way as `binary_gender/1`, but it returns a non-binary gender
  string instead.
  """
  @spec non_binary_gender(Keyword.t()) :: String.t()
  def non_binary_gender(opts \\ []),
    do: random_value(__MODULE__, @gender_file, "non_binary", opts)

  @doc """
  Generates a random age.

  Returns an age as a non-negative integer between `0` and `120` by default.

  ## Examples

      iex> NeoFaker.Person.age()
      44

      iex> NeoFaker.Person.age(7, 44)
      27

  """
  @spec age(non_neg_integer(), non_neg_integer()) :: non_neg_integer()
  def age(min \\ 0, max \\ 120) when min >= 0 and min <= max, do: Enum.random(min..max)
end
