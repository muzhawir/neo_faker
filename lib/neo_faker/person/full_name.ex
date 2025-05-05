defmodule NeoFaker.Person.FullName do
  @moduledoc false

  alias NeoFaker.Person

  
  
  @doc """
  Generates a random full name for a specified gender and locale, with optional inclusion of a middle name.
  
  If `:unisex` is provided as the gender, randomly selects between a male or female full name.
  """
  def generate_random_full_name(:unisex, locale, include_middle_name?) do
    Enum.random([
      generate_full_name(:male, locale, include_middle_name?),
      generate_full_name(:female, locale, include_middle_name?)
    ])
  end

  @doc """
  Generates a random male full name for the specified locale, optionally including a middle name.
  
  ## Parameters
  
  - `locale`: A keyword list specifying locale options.
  - `include_middle_name?`: If `true`, includes a middle name in the generated full name.
  
  ## Returns
  
  A string containing the generated male full name.
  """
  def generate_random_full_name(:male, locale, include_middle_name?) do
    generate_full_name(:male, locale, include_middle_name?)
  end

  @doc """
  Generates a random female full name based on the specified locale and whether to include a middle name.
  
  Returns a full name string using female name components appropriate for the given locale.
  """
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
    [first_name, _middle_name, last_name] =
      sex |> generate_full_name(locale, true) |> String.split(" ")

    "#{first_name} #{last_name}"
  end
end
