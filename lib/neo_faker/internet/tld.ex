defmodule NeoFaker.Internet.TLD do
  @moduledoc false

  alias NeoFaker.Data.Cache
  alias NeoFaker.Data.Generator

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
        :default
        |> Cache.fetch!(@module, @tld_file)
        |> Map.delete("safe")
        |> Map.values()
        |> List.flatten()
        |> Enum.random()

      :all ->
        :default
        |> Cache.fetch!(@module, @tld_file)
        |> Map.values()
        |> List.flatten()
        |> Enum.random()

      :safe ->
        Generator.random_value(@module, @tld_file, "safe")

      :generic ->
        Generator.random_value(@module, @tld_file, "generic")

      :sponsored ->
        Generator.random_value(@module, @tld_file, "sponsored")

      :country_code ->
        Generator.random_value(@module, @tld_file, "country_code")

      _ ->
        Generator.random_value(@module, @tld_file, "all_except_safe")
    end
  end
end
