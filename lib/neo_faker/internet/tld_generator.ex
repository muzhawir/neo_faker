defmodule NeoFaker.Internet.TldGenerator do
  @moduledoc false

  alias NeoFaker.Data

  @type tld_type :: :all | :all_except_safe | :safe | :generic | :sponsored | :country_code

  @module NeoFaker.Internet

  @tld_file "tld.exs"

  @doc """
  Generates a random top-level domain (TLD) based on the specified type.

  Returns a random TLD string.
  """
  @spec generate_name(tld_type()) :: String.t()
  def generate_name(type) do
    case type do
      :all_except_safe ->
        generate_default_name()

      :all ->
        :default
        |> Data.fetch!(@module, @tld_file)
        |> Map.values()
        |> List.flatten()
        |> Enum.random()

      :safe ->
        Data.random_value(@module, @tld_file, "safe")

      :generic ->
        Data.random_value(@module, @tld_file, "generic")

      :sponsored ->
        Data.random_value(@module, @tld_file, "sponsored")

      :country_code ->
        Data.random_value(@module, @tld_file, "country_code")
    end
  end

  defp generate_default_name do
    :default
    |> Data.fetch!(@module, @tld_file)
    |> Map.delete("safe")
    |> Map.values()
    |> List.flatten()
    |> Enum.random()
  end
end
