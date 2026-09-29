defmodule NeoFaker.Person.NameGenerator do
  @moduledoc false

  alias NeoFaker.Data

  @files [female: "female_name.exs", male: "male_name.exs"]
  @affixes_file "name_affixes.exs"

  @type sex :: :unisex | :female | :male

  @doc """
  Returns a random name part for `sex`.

  `key` is `"first_names"`, `"middle_names"`, or `"last_names"`. `:unisex` first picks
  the female or male list with equal probability, then draws once from it.
  """
  @spec name(atom() | nil, String.t(), sex()) :: String.t()
  def name(locale, key, sex) do
    file = Keyword.fetch!(@files, resolve_sex(sex))
    Data.random_value(NeoFaker.Person, file, key, locale: locale)
  end

  @doc """
  Returns a random name prefix suitable for `sex`.

  Every sex draws from the neutral `"prefixes"`; `:female` and `:male` add their own
  titles, and `:unisex` adds both.
  """
  @spec prefix(atom() | nil, sex()) :: String.t()
  def prefix(locale, sex) do
    keys =
      case sex do
        :unisex -> ["prefixes", "female_prefixes", "male_prefixes"]
        :female -> ["prefixes", "female_prefixes"]
        :male -> ["prefixes", "male_prefixes"]
      end

    Data.random_value(NeoFaker.Person, @affixes_file, keys, locale: locale)
  end

  @doc """
  Replaces `:unisex` with `:female` or `:male`, picked at random.
  """
  @spec resolve_sex(sex()) :: :female | :male
  def resolve_sex(:unisex), do: Enum.random([:female, :male])
  def resolve_sex(sex) when sex in [:female, :male], do: sex
end
