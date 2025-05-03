defmodule NeoFaker.Person.Name do
  @moduledoc false

  import NeoFaker.Data.Generator, only: [random_data: 4]

  @module NeoFaker.Person
  @female_name_file "female_name.exs"
  @male_name_file "male_name.exs"

  @doc """
  Generates a random name.

  Returns a random name based on the provided options.
  """
  @spec generate_random_name(atom(), String.t(), atom()) :: String.t()
  def generate_random_name(locale, key, :female) do
    random_data(@module, @female_name_file, key, locale: locale)
  end

  def generate_random_name(locale, key, :male) do
    random_data(@module, @male_name_file, key, locale: locale)
  end

  def generate_random_name(locale, key, :unisex) do
    Enum.random([
      random_data(@module, @female_name_file, key, locale: locale),
      random_data(@module, @male_name_file, key, locale: locale)
    ])
  end
end
