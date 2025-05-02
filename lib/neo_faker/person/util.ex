defmodule NeoFaker.Person.Util do
  @moduledoc false

  import NeoFaker.Data.Generator, only: [random_data: 4]

  alias NeoFaker.Person

  @female_name_file "female_name.exs"
  @male_name_file "male_name.exs"
  @module NeoFaker.Person

  @doc """
  Generates a random name.

  Returns a random name based on the provided options.
  """
  @spec random_name(atom(), String.t(), atom()) :: String.t()
  def random_name(locale, key, :female) do
    random_data(@module, @female_name_file, key, locale: locale)
  end

  def random_name(locale, key, :male) do
    random_data(@module, @male_name_file, key, locale: locale)
  end

  def random_name(locale, key, :unisex) do
    Enum.random([
      random_data(@module, @female_name_file, key, locale: locale),
      random_data(@module, @male_name_file, key, locale: locale)
    ])
  end

  @doc """
  Generates a random full name.

  If no options are provided, it returns a default random unisex full name.
  """
  @spec random_full_name(atom(), Keyword.t(), boolean()) :: String.t()
  def random_full_name(:unisex, locale, include_middle_name?) do
    Enum.random([
      generate_full_name(:male, locale, include_middle_name?),
      generate_full_name(:female, locale, include_middle_name?)
    ])
  end

  def random_full_name(:male, locale, include_middle_name?) do
    generate_full_name(:male, locale, include_middle_name?)
  end

  def random_full_name(:female, locale, include_middle_name?) do
    generate_full_name(:female, locale, include_middle_name?)
  end

  # Generates a full name with or without a middle name.
  defp generate_full_name(sex, locale, true) do
    first_name = Person.first_name(sex: sex, locale: locale)
    middle_name = Person.middle_name(sex: sex, locale: locale)
    last_name = Person.last_name(sex: sex, locale: locale)

    "#{first_name} #{middle_name} #{last_name}"
  end

  defp generate_full_name(sex, locale, false) do
    [first_name, _middle_name, last_name] =
      sex |> generate_full_name(locale, true) |> String.split(" ")

    "#{first_name} #{last_name}"
  end
end
