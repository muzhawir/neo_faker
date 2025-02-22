defmodule NeoFaker.Person do
  @moduledoc """
  Provides functions for generating person-related information.

  This module includes functions to generate random person-related information, such as names, ages,
  and genders.
  """
  @moduledoc since: "0.6.0"

  import NeoFaker.Helper.Locale, only: [random_value: 3]
  import NeoFaker.Person.Utils

  @module __MODULE__
  @unisex_name_file "unisex_name.exs"
  @name_affix_file "name_affixes.exs"
  @masculine_name_file "masculine_name.exs"
  @feminine_name_file "feminine_name.exs"
  @gender_file "gender.exs"

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
  def first_name(opts \\ [])
  def first_name([]), do: @module |> load_all_random_names("first_names") |> Enum.random()
  def first_name(type: :unisex), do: random_value(@module, @unisex_name_file, "first_names")
  def first_name(type: :masculine), do: random_value(@module, @masculine_name_file, "first_names")
  def first_name(type: :feminine), do: random_value(@module, @feminine_name_file, "first_names")

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
  def middle_name(opts \\ [])
  def middle_name([]), do: @module |> load_all_random_names("middle_names") |> Enum.random()
  def middle_name(type: :unisex), do: random_value(@module, @unisex_name_file, "middle_names")
  def middle_name(type: :masculine), do: random_value(@module, @masculine_name_file, "middle_names")
  def middle_name(type: :feminine), do: random_value(@module, @feminine_name_file, "middle_names")

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
  def last_name(opts \\ [])
  def last_name([]), do: @module |> load_all_random_names("last_names") |> Enum.random()
  def last_name(type: :unisex), do: random_value(@module, @unisex_name_file, "last_names")
  def last_name(type: :masculine), do: random_value(@module, @masculine_name_file, "last_names")
  def last_name(type: :feminine), do: random_value(@module, @feminine_name_file, "last_names")

  @doc """
  Returns a random name prefix.

  ## Examples

      iex> NeoFaker.Person.prefix()
      "Mr."

  """
  @spec prefix() :: String.t()
  def prefix, do: random_value(@module, @name_affix_file, "prefixes")

  @doc """
  Returns a random name suffix.

  ## Examples

      iex> NeoFaker.Person.suffix()
      "Jr."

  """
  @doc since: "0.7.0"
  @spec suffix() :: String.t()
  def suffix, do: random_value(@module, @name_affix_file, "suffixes")

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
  @spec binary_gender() :: String.t()
  def binary_gender, do: random_value(@module, @gender_file, "binary")

  @doc """
  Returns random short binary gender.

  The gender is either "M" or "F".

  ## Examples

      iex> NeoFaker.Person.short_binary_gender()
      "F"

  """
  @spec short_binary_gender() :: String.t()
  def short_binary_gender, do: random_value(@module, @gender_file, "short_binary")

  @doc """
  Returns random non-binary gender.

  The gender is a non-binary gender, such as "Agender", "Androgyne", "Bigender", etc.

  ## Examples

      iex> NeoFaker.Person.non_binary_gender()
      "Agender"

  """
  @spec non_binary_gender() :: String.t()
  def non_binary_gender, do: random_value(@module, @gender_file, "non_binary")
end
