defmodule NeoFaker.Person do
  @moduledoc """
  Provides functions for generating person-related information.

  This module includes functions to generate random person-related information, such as names, ages,
  and genders.
  """
  @moduledoc since: "0.6.0"

  import NeoFaker.Helper.Locale, only: [random_value: 4]

  @typedoc "Random result in the form of a string or a list of strings."
  @type result :: String.t() | [String.t()]

  @module __MODULE__

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

      iex> NeoFaker.Person.binary_gender(2)
      ["Male", "Female"]

  """
  @spec binary_gender(non_neg_integer()) :: result()
  def binary_gender(amount \\ 1) when amount in 1..2 do
    random_value(@module, "gender.exs", "binary", amount)
  end

  @doc """
  Returns random short binary gender.

  The gender is either "M" or "F".

  ## Examples

      iex> NeoFaker.Person.short_binary_gender()
      "F"

      iex> NeoFaker.Person.short_binary_gender(2)
      ["M", "F"]

  """
  @spec short_binary_gender(non_neg_integer()) :: result()
  def short_binary_gender(amount \\ 1) when amount in 1..2 do
    random_value(@module, "gender.exs", "short_binary", amount)
  end

  @doc """
  Returns random non-binary gender.

  The gender is a non-binary gender, such as "Agender", "Androgyne", "Bigender", etc.

  ## Examples

      iex> NeoFaker.Person.non_binary_gender()
      "Agender"

      iex> NeoFaker.Person.non_binary_gender(2)
      ["Agender", "Androgyne"]

  """
  @spec non_binary_gender(non_neg_integer()) :: result()
  def non_binary_gender(amount \\ 1) do
    random_value(@module, "gender.exs", "non_binary", amount)
  end
end
