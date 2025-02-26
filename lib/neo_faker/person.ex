defmodule NeoFaker.Person do
  @moduledoc """
  Provides functions for generating person-related information.

  This module includes functions to generate random person-related information, such as names, ages,
  and genders.
  """
  @moduledoc since: "0.6.0"

  import NeoFaker.Helper.Generator, only: [random: 4]
  import NeoFaker.Person.Util

  @module __MODULE__
  @gender_file "gender.exs"
  @name_affixes_file "name_affixes.exs"

  @doc """
  Returns a random first name.

  Returns a random first name, if no options are provided it will return a random unisex,
  masculine, or feminine name.

  ## Options

  The accepted options are:

    - `:type` - Specifies the type of name to generate.

  The values for `:type` can be:

    - `:unisex` - Generates a random unisex name.
    - `:masculine` - Generates a random masculine name.
    - `:feminine` - Generates a random feminine name.

  ## Examples

      iex> NeoFaker.Person.first_name()
      "Tiffany"

      iex> NeoFaker.Person.first_name(type: :masculine)
      "Theodore"

  """
  @doc since: "0.7.0"
  @spec first_name(Keyword.t()) :: String.t()
  def first_name(opts \\ []), do: random_name(@module, "first_names", opts)

  @doc """
  Returns a random middle name.

  Returns a random middle name, if no options are provided it will return a random unisex,
  masculine, or feminine name.

  ## Options

  The accepted options are:

    - `:type` - Specifies the type of name to generate.

  The values for `:type` can be:

    - `:unisex` - Generates a random unisex name.
    - `:masculine` - Generates a random masculine name.
    - `:feminine` - Generates a random feminine name.

  ## Examples

      iex> NeoFaker.Person.middle_name()
      "Arden"

      iex> NeoFaker.Person.middle_name(type: :feminine)
      "Juliette"

  """
  @doc since: "0.7.0"
  @spec middle_name(Keyword.t()) :: String.t()
  def middle_name(opts \\ []), do: random_name(@module, "middle_names", opts)

  @doc """
  Returns a random last name.

  Returns a random last name, if no options are provided it will return a random unisex,
  masculine, or feminine name.

  ## Options

  The accepted options are:

    - `:type` - Specifies the type of name to generate.

  The values for `:type` can be:

    - `:unisex` - Generates a random unisex name.
    - `:masculine` - Generates a random masculine name.
    - `:feminine` - Generates a random feminine name.

  ## Examples

      iex> NeoFaker.Person.last_name()
      "Norris"

      iex> NeoFaker.Person.last_name(type: :unisex)
      "Harris"

  """
  @doc since: "0.7.0"
  @spec last_name(Keyword.t()) :: String.t()
  def last_name(opts \\ []), do: random_name(@module, "last_names", opts)

  @doc """
  Returns a random full name.

  Returns a random full name, if no options are provided it will return a default random unisex
  full name.

  ## Options

  The accepted options are:

    - `:locale` - Specifies the locale to use.
    - `:sex` - Specifies the sex of the name to generate.
    - `:middle_name` - Specifies whether to include a middle name in the full name.

  ## Examples

      iex> NeoFaker.Person.full_name()
      "Tiffany Norris Jr."

      iex> NeoFaker.Person.full_name(sex: :male)
      "Theodore Buckley Jr."

      iex> NeoFaker.Person.full_name(middle_name: false)
      "Tiffany Norris"

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
  Returns a random name prefix.

  ## Examples

      iex> NeoFaker.Person.prefix()
      "Mr."

  """

  @spec prefix(Keyword.t()) :: String.t()
  def prefix(opts \\ []), do: random(@module, @name_affixes_file, "prefixes", opts)

  @doc """
  Returns a random name suffix.

  ## Examples

      iex> NeoFaker.Person.suffix()
      "Jr."

  """
  @doc since: "0.7.0"
  @spec suffix(Keyword.t()) :: String.t()
  def suffix(opts \\ []), do: random(@module, @name_affixes_file, "suffixes", opts)

  @doc """
  Returns random age.

  The age is a non-negative integer between 0 and 120.

  ## Examples

      iex> NeoFaker.Person.age()
      44

      iex> NeoFaker.Person.age(7..44)
      27

  """
  @spec age(non_neg_integer(), non_neg_integer()) :: non_neg_integer()
  def age(min \\ 0, max \\ 120) when min >= 0 and min <= max, do: Enum.random(min..max)

  @doc """
  Returns random binary gender.

  The gender is either "Male" or "Female".

  ## Examples

      iex> NeoFaker.Person.binary_gender()
      "Male"

  """
  @spec binary_gender(Keyword.t()) :: String.t()
  def binary_gender(opts \\ []), do: random(@module, @gender_file, "binary", opts)

  @doc """
  Returns random short binary gender.

  The gender is either "M" or "F".

  ## Examples

      iex> NeoFaker.Person.short_binary_gender()
      "F"

  """
  @spec short_binary_gender(Keyword.t()) :: String.t()
  def short_binary_gender(opts \\ []), do: random(@module, @gender_file, "short_binary", opts)

  @doc """
  Returns random non-binary gender.

  The gender is a non-binary gender, such as "Agender", "Androgyne", "Bigender", etc.

  ## Examples

      iex> NeoFaker.Person.non_binary_gender()
      "Agender"

  """
  @spec non_binary_gender(Keyword.t()) :: String.t()
  def non_binary_gender(opts \\ []), do: random(@module, @gender_file, "non_binary", opts)
end
