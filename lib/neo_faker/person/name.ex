defmodule NeoFaker.Person.Name do
  @moduledoc false

  import NeoFaker.Data.Generator, only: [random_value: 4]

  @module NeoFaker.Person
  @female_name_file "female_name.exs"
  @male_name_file "male_name.exs"

  @doc """
  Generates a random female name for the specified locale and key.

  Returns a name string selected from female name data corresponding to the given locale and key.
  """
  @spec generate_random_name(atom(), String.t(), atom()) :: String.t()
  def generate_random_name(locale, key, :female) do
    random_value(@module, @female_name_file, key, locale: locale)
  end

  def generate_random_name(locale, key, :male) do
    random_value(@module, @male_name_file, key, locale: locale)
  end

  def generate_random_name(locale, key, :unisex) do
    Enum.random([
      random_value(@module, @female_name_file, key, locale: locale),
      random_value(@module, @male_name_file, key, locale: locale)
    ])
  end
end
