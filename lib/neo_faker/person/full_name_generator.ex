defmodule NeoFaker.Person.FullNameGenerator do
  @moduledoc false

  # Combines first/middle/last name lookups (via NeoFaker.Person) into one
  # full-name string, resolving :unisex to a single concrete sex per call so a
  # name's parts never mix male and female word lists.

  alias NeoFaker.Person

  @doc """
  Generates a random full name for a specified sex and locale.

  `sex` is `:male`, `:female`, or `:unisex` (which picks one of the other two at random, once per
  call, before delegating). `locale` is a locale atom, or `nil` to use the configured default.
  """
  @spec name(atom(), atom() | nil, boolean()) :: String.t()
  def name(:unisex, locale, include_middle_name?) do
    generate_full_name(Enum.random([:male, :female]), locale, include_middle_name?)
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
