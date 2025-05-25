defmodule NeoFaker.Person.Name do
  @moduledoc false

  import NeoFaker.Data.Generator, only: [random_value: 4]

  @module NeoFaker.Person
  @female_name_file "female_name.exs"
  @male_name_file "male_name.exs"

  @doc """
  Generates a random name for the specified locale, key, and gender.

  Returns a name string selected from the appropriate name data file for the given gender.
  If `:unisex` is provided, randomly selects from both male and female names.
  """
  @spec generate_random_name(atom(), String.t(), atom()) :: String.t()
  def generate_random_name(locale, key, gender) do
    case gender do
      :female ->
        random_value(@module, @female_name_file, key, locale: locale)

      :male ->
        random_value(@module, @male_name_file, key, locale: locale)

      :unisex ->
        Enum.random([
          random_value(@module, @female_name_file, key, locale: locale),
          random_value(@module, @male_name_file, key, locale: locale)
        ])

      other ->
        raise ArgumentError,
              "Invalid gender: #{inspect(other)}. Expected :female, :male, or :unisex."
    end
  end
end
