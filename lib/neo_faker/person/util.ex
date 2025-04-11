defmodule NeoFaker.Person.Util do
  @moduledoc false

  import NeoFaker.Helper.Generator, only: [random: 4]

  alias NeoFaker.Person

  @female_name_file "female_name.exs"
  @male_name_file "male_name.exs"

  @doc """
  Generates a random name.

  If no options are provided, it returns a random unisex name.
  """
  @spec random_name(atom(), String.t(), Keyword.t()) :: String.t()
  def random_name(module, key, opts \\ []) do
    locale = Keyword.get(opts, :locale, :default)
    female_name = random(module, @female_name_file, key, locale: locale)
    male_name = random(module, @male_name_file, key, locale: locale)

    case Keyword.get(opts, :sex, nil) do
      nil -> Enum.random([female_name, male_name])
      :female -> female_name
      :male -> male_name
    end
  end

  @doc """
  Generates a random full name.

  If no options are provided, it returns a default random unisex full name.
  """
  @spec random_full_name(atom(), Keyword.t(), boolean()) :: String.t()
  def random_full_name(nil, locale, include_middle_name?) do
    male_name = generate_full_name(:male, locale, include_middle_name?)
    female_name = generate_full_name(:female, locale, include_middle_name?)

    Enum.random([male_name, female_name])
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
