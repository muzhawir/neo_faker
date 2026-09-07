defmodule NeoFaker.Person.NameGenerator do
  @moduledoc false

  alias NeoFaker.Data

  # Hardcoded to NeoFaker.Person (not __MODULE__) because NeoFaker.Data derives
  # the priv/data subdirectory from this module's last name segment, lowercased.
  # Using __MODULE__ here would look up priv/data/<locale>/namegenerator/... instead
  # of the real priv/data/<locale>/person/... directory.
  @module NeoFaker.Person
  @female_name_file "female_name.exs"
  @male_name_file "male_name.exs"

  @doc """
  Generates a random name for the specified locale, gender, and data-file key.

  `key` is one of `"first_names"`, `"middle_names"`, or `"last_names"`, matching
  the map keys in `female_name.exs`/`male_name.exs`. `:unisex` picks uniformly
  from both the female and male draw for that key, rather than picking a sex
  first and then drawing once (so a unisex first name and a unisex last name
  from the same call aren't correlated to the same underlying sex).
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
