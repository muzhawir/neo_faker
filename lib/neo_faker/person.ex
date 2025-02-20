defmodule NeoFaker.Person do
  @moduledoc """
  Provides functions for generating person-related information.

  This module includes functions to generate random person-related information, such as names, ages,
  and genders.
  """
  @moduledoc since: "0.6.0"

  import NeoFaker.Helper.Locale, only: [random_value: 3]

  @module __MODULE__
  @unisex_name_file "unisex_name.exs"
  @name_affix_file "name_affixes.exs"
  @gender_file "gender.exs"

  @spec first_name() :: String.t()
  def first_name, do: random_value(@module, @unisex_name_file, "first_names")

  @spec middle_name() :: String.t()
  def middle_name, do: random_value(@module, @unisex_name_file, "middle_names")

  @spec last_name() :: String.t()
  def last_name, do: random_value(@module, @unisex_name_file, "last_names")

  @spec prefix() :: String.t()
  def prefix, do: random_value(@module, @name_affix_file, "prefixes")

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
