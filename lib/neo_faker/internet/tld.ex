defmodule NeoFaker.Internet.TLD do
  @moduledoc false

  alias NeoFaker.Data.Cache
  alias NeoFaker.Data.Generator

  @module NeoFaker.Internet

  @tld_file "tld.exs"

  def name(type) do
    case type do
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

      other ->
        raise ArgumentError,
              "Invalid TLD type: #{inspect(other)}. " <>
                "Expected :all, :safe, :generic, :sponsored, or :country_code."
    end
  end
end
