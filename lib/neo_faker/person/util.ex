defmodule NeoFaker.Person.Util do
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
      nil -> module |> unisex_name(key, opts) |> Enum.random()
      :female -> random(module, @female_name_file, key, opts)
      :male -> random(module, @male_name_file, key, opts)
    end
  end

  # Retuns a random unisex name from the persistent term
  def unisex_name(module, key, opts \\ []) do
    locale = Keyword.get(opts, :locale) || Application.get_env(:neo_faker, :locale)
    male_data = fetch_data(module, @male_name_file, locale: locale)
    female_data = fetch_data(module, @female_name_file, locale: locale)
    unisex_name_key = Locale.persistent_term_key(locale, module, "unisex_name")

    case :persistent_term.get(unisex_name_key, nil) do
      nil ->
        unisex_data = Map.merge(male_data, female_data, &merge_lists/3)

        :persistent_term.put(unisex_name_key, unisex_data)

        unisex_name_key |> :persistent_term.get() |> Map.get(key)

      unisex_data ->
        Map.get(unisex_data, key)
    end
  end

  # Merges two lists and returns a shuffled list
  defp merge_lists(_key, first_list, second_list) do
    first_list |> Stream.concat(second_list) |> Enum.shuffle()
  end
end
