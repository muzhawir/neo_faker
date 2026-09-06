defmodule NeoFaker.Person.FullNameGenerator do
  @moduledoc false

  alias NeoFaker.Person

  @doc """
  Generates a random full name for a specified gender and locale.

  If `:unisex` is provided as the gender, randomly selects between a male or female full name.
  """
  @spec name(atom(), keyword(), boolean()) :: String.t()
  def name(:unisex, locale, include_middle_name?) do
    generate_full_name(
      Enum.random([:male, :female]),
      locale,
      include_middle_name?
    )
  end

  def name(sex, locale, include_middle_name?) when sex in [:male, :female] do
    generate_full_name(sex, locale, include_middle_name?)
  end

  # Generates a full name with or without a middle name.
  defp generate_full_name(sex, locale, true) do
    full_name = [
      Person.first_name(sex: sex, locale: locale),
      Person.middle_name(sex: sex, locale: locale),
      Person.last_name(sex: sex, locale: locale)
    ]

    Enum.join(full_name, " ")
  end

  defp generate_full_name(sex, locale, false) do
    full_name = [
      Person.first_name(sex: sex, locale: locale),
      Person.last_name(sex: sex, locale: locale)
    ]

    Enum.join(full_name, " ")
  end
end
