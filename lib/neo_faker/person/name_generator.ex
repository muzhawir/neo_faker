defmodule NeoFaker.Person.NameGenerator do
  @moduledoc false

  alias NeoFaker.Data

  @module NeoFaker.Person
  @female_name_file "female_name.exs"
  @male_name_file "male_name.exs"

  @doc """
  Generates a random name for the specified locale, key, and gender.

  Returns a name string selected from the appropriate name data file for the given gender.
  If `:unisex` is provided, randomly selects from both male and female names.
  """
  @spec name(atom(), String.t(), atom()) :: String.t()
  def name(locale, key, gender) do
    case gender do
      :female ->
        Data.random_value(@module, @female_name_file, key, locale: locale)

      :male ->
        Data.random_value(@module, @male_name_file, key, locale: locale)

      :unisex ->
        Enum.random([
          Data.random_value(@module, @female_name_file, key, locale: locale),
          Data.random_value(@module, @male_name_file, key, locale: locale)
        ])
    end
  end
end
