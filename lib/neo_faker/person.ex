defmodule NeoFaker.Person do
  @moduledoc """
  Provides functions for generating person-related information.

  This module offers a variety of functions to generate random personal details, such as names,
  ages, and genders.
  """
  @moduledoc since: "0.6.0"

  import NeoFaker.Helper.Generator, only: [random: 4]
  import NeoFaker.Person.Util

  @module __MODULE__
  @gender_file "gender.exs"
  @name_affixes_file "name_affixes.exs"

  @doc """
  Generates a random first name.

  If no options are provided, it returns a random unisex first name.

  ## Options

  The accepted options are:

  - `:type` - Specifies the type of name to generate.
  - `:locale` - Specifies the locale to use.

  Values for option `:type` can be:

  - `nil` - Generates a random unisex name (default).
  - `:male` - Generates a random male name.
  - `:female` - Generates a random female name.

  Values for option `:locale` can be:

  - `nil` - Uses the default locale `:default`.
  - `:id_id` - Uses the Indonesian locale, for example.

  ## Examples

      iex> NeoFaker.Person.first_name()
      "Julia"

      iex> NeoFaker.Person.first_name(type: :male)
      "José"

      iex> NeoFaker.Person.first_name(locale: "id_id")
      "Jaka"

  """
  @doc since: "0.7.0"
  @spec first_name(Keyword.t()) :: String.t()
  def first_name(opts \\ []), do: random_name(@module, "first_names", opts)

  @doc """
  Generates a random middle name.

  This function behaves the same way as `first_name/1`. See `first_name/1` for more details.
  """
  @doc since: "0.7.0"
  @spec middle_name(Keyword.t()) :: String.t()
  def middle_name(opts \\ []), do: random_name(@module, "middle_names", opts)

  @doc """
  Generates a random last name.

  This function behaves the same way as `first_name/1`. See `first_name/1` for more details.
  """
  @doc since: "0.7.0"
  @spec last_name(Keyword.t()) :: String.t()
  def last_name(opts \\ []), do: random_name(@module, "last_names", opts)

  @doc """
  Generates a random full name.

  If no options are provided, it returns a default random unisex full name.

  ## Options

  The accepted options are:

  - `:locale` - Specifies the locale to use.
  - `:sex` - Specifies the sex of the generated name.
  - `:middle_name` - Determines whether to include a middle name in the full name.

  Values for option `:locale` can be:

  - `nil` - Uses the default locale `:default`.
  - `:id_id` - Uses the Indonesian locale, for example.

  Values for option `:sex` can be:

  - `nil` - Generates a random unisex name (default).
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
    locale = Keyword.get(opts, :locale)
    sex = Keyword.get(opts, :sex)
    include_middle_name? = Keyword.get(opts, :middle_name, true)

    random_full_name(locale, sex, include_middle_name?)
  end

  @doc """
  Generates a random name prefix.

  ## Examples

      iex> NeoFaker.Person.prefix()
      "Mr."

  """

  @spec prefix(Keyword.t()) :: String.t()
  def prefix(opts \\ []), do: random(@module, @name_affixes_file, "prefixes", opts)

  @doc """
  Generates a random name suffix.

  ## Examples

      iex> NeoFaker.Person.suffix()
      "IV"

  """
  @doc since: "0.7.0"
  @spec suffix(Keyword.t()) :: String.t()
  def suffix(opts \\ []), do: random(@module, @name_affixes_file, "suffixes", opts)

  @doc """
  Generates a random age.

  The age is a non-negative integer between `0` and `120` by default.

  ## Examples

      iex> NeoFaker.Person.age()
      44

      iex> NeoFaker.Person.age(7, 44)
      27

  """
  @spec age(non_neg_integer(), non_neg_integer()) :: non_neg_integer()
  def age(min \\ 0, max \\ 120) when min >= 0 and min <= max, do: Enum.random(min..max)

  @doc """
  Generates a random binary gender.

  Returns either `"Male"` or `"Female"`.

  ## Examples

      iex> NeoFaker.Person.binary_gender()
      "Male"

  """
  @spec binary_gender(Keyword.t()) :: String.t()
  def binary_gender(opts \\ []), do: random(@module, @gender_file, "binary", opts)

  @doc """
  Generates a random short binary gender.

  Returns either `"M"` or `"F"`.

  ## Examples

      iex> NeoFaker.Person.short_binary_gender()
      "F"

  """
  @spec short_binary_gender(Keyword.t()) :: String.t()
  def short_binary_gender(opts \\ []), do: random(@module, @gender_file, "short_binary", opts)

  @doc """
  Generates a random non-binary gender.

  Returns a non-binary gender, such as `"Agender"`, `"Androgyne"`, `"Bigender"`, etc.

  ## Examples

      iex> NeoFaker.Person.non_binary_gender()
      "Agender"

  """
  @spec non_binary_gender(Keyword.t()) :: String.t()
  def non_binary_gender(opts \\ []), do: random(@module, @gender_file, "non_binary", opts)
end
