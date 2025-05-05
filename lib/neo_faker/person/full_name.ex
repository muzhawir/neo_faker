defmodule NeoFaker.Person.FullName do
  @moduledoc false

  alias NeoFaker.Person

  @doc """
  Generates a random full name for a specified gender and locale.

  If `:unisex` is provided as the gender, randomly selects between a male or female full name.
  """
  @spec generate_random_full_name(atom(), Keyword.t(), boolean()) :: String.t()
  def generate_random_full_name(:unisex, locale, include_middle_name?) do
    Enum.random([
      generate_full_name(:male, locale, include_middle_name?),
      generate_full_name(:female, locale, include_middle_name?)
    ])
  end

  def generate_random_full_name(:male, locale, include_middle_name?) do
    generate_full_name(:male, locale, include_middle_name?)
  end

  def generate_random_full_name(:female, locale, include_middle_name?) do
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
    first_name = Person.first_name(sex: sex, locale: locale)
    last_name = Person.last_name(sex: sex, locale: locale)

    "#{first_name} #{last_name}"
  end
end
