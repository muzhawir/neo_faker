defmodule NeoFaker.Person.Name do
  @moduledoc false

  import NeoFaker.Data.Generator, only: [random_data: 4]

  @module NeoFaker.Person
  @female_name_file "female_name.exs"
  @male_name_file "male_name.exs"

  
  
  @doc """
  Generates a random female name for the specified locale and key.
  
  Returns a name string selected from female name data corresponding to the given locale and key.
  """
  def generate_random_name(locale, key, :female) do
    random_data(@module, @female_name_file, key, locale: locale)
  end

  @doc """
  Generates a random male name for the specified locale and key.
  
  Returns a string representing a randomly selected male name.
  """
  def generate_random_name(locale, key, :male) do
    random_data(@module, @male_name_file, key, locale: locale)
  end

  @doc """
  Generates a random person name for the given locale and key by randomly selecting from both female and male name data.
  
  Returns a name as a string.
  """
  def generate_random_name(locale, key, :unisex) do
    Enum.random([
      random_data(@module, @female_name_file, key, locale: locale),
      random_data(@module, @male_name_file, key, locale: locale)
    ])
  end
end
