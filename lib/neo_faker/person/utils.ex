defmodule NeoFaker.Person.Utils do
  @moduledoc false

  import NeoFaker.Helper.Generator, only: [random: 4]

  @female_name_file "female_name.exs"
  @male_name_file "male_name.exs"

  # @unisex_name_file "unisex_name.exs"
  # @masculine_name_file "masculine_name.exs"
  # @feminine_name_file "feminine_name.exs"
  # @persistent_data "neo_faker_person_all_names"

  @doc """
  Returns a random name.
  """
  @spec random_name(atom(), String.t(), Keyword.t()) :: String.t()
  def random_name(module, key, opts \\ []) do
    file =
      case Keyword.get(opts, :sex, :female) do
        :female -> @female_name_file
        :male -> @male_name_file
      end

    random(module, file, key, opts)
  end

  @doc """
  Returns a list of all random names.

  Returns a list of all random names, if list is not yet existing in persistent term it will be created.
  """
  # @spec load_all_random_names(atom(), String.t()) :: list()
  # def load_all_random_names(module, key) do
  #   case :persistent_term.get("neo_faker_person_all_names", nil) do
  #     nil ->
  #       store_all_names(module)

  #       @persistent_data |> :persistent_term.get() |> Map.get(key, [])

  #     all_names ->
  #       Map.get(all_names, key, [])
  #   end
  # end

  # Stores all random names in persistent term.
  #
  # Stores combined random unisex, masculine, and feminine names in persistent term.
  # defp store_all_names(module) do
  #   all_names = %{
  #     "first_names" => combine_names_list(module, "first_names"),
  #     "middle_names" => combine_names_list(module, "middle_names"),
  #     "last_names" => combine_names_list(module, "last_names")
  #   }

  #   :persistent_term.put(@persistent_data, all_names)
  # end

  # Combines unisex, masculine, and feminine names into one list.
  # defp combine_names_list(module, key) do
  #   all_names = [
  #     read_persistent_term(module, @unisex_name_file, key),
  #     read_persistent_term(module, @masculine_name_file, key),
  #     read_persistent_term(module, @feminine_name_file, key)
  #   ]

  #   all_names |> List.flatten() |> Enum.shuffle()
  # end
end
