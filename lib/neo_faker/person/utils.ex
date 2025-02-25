defmodule NeoFaker.Person.Utils do
  @moduledoc false

  import NeoFaker.Helper.Generator, only: [fetch_data: 3, random: 4]

  alias NeoFaker.Helper.Locale

  @female_name_file "female_name.exs"
  @male_name_file "male_name.exs"

  @doc """
  Returns a random name.

  Returns a random name, if no options are provided it will return a random unisex name.
  """
  @spec random_name(atom(), String.t(), Keyword.t()) :: String.t()
  def random_name(module, key, opts \\ []) do
    case Keyword.get(opts, :sex) do
      nil -> random_unisex_name(module, key, opts)
      :female -> random(module, @female_name_file, key, opts)
      :male -> random(module, @male_name_file, key, opts)
    end
  end

  # Merges the male and female data names and returns a random unisex name
  defp random_unisex_name(module, key, opts) do
    locale = Keyword.get(opts, :locale) || Application.get_env(:neo_faker, :locale)
    male_names = fetch_data(module, @male_name_file, locale: locale)
    female_names = fetch_data(module, @female_name_file, locale: locale)
    persisent_term_key = Locale.persistent_term_key(locale, module, "unisex_name")

    unisex_names =
      Map.merge(male_names, female_names, fn _key, male, female ->
        male |> Stream.concat(female) |> Enum.shuffle()
      end)

    case :persistent_term.get(persisent_term_key, nil) do
      nil ->
        :persistent_term.put(persisent_term_key, unisex_names)

        persisent_term_key |> :persistent_term.get() |> Map.get(key) |> Enum.random()

      term ->
        term |> Map.get(key) |> Enum.random()
    end
  end
end
