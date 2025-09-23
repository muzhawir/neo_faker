defmodule NeoFaker.Internet do
  @moduledoc """
  Functions for generating internet-related data.

  This module provides utilities to generate random internet-related information, such as email
  addresses, domain names, URLs, IP addresses, and MAC addresses.
  """
  @moduledoc since: "0.13.0"

  alias NeoFaker.Internet.TLD

  @doc """
  Generates a random top-level domain (TLD).

  Returns a random TLD string.

  ## Options

  The accepted options are:

  - `:dot` - A boolean indicating whether to include a leading dot in the TLD. Defaults to `true`.
  - `:type` - Specifies the type of TLD to generate.

  The values for `:type` can be:

  - `:all` - Returns a TLD from all available types (default).
  - `:safe` - Returns a safe TLD, e.g. `.example`.
  - `:generic` - Returns a generic TLD, e.g. `.com`.
  - `:sponsored` - Returns a sponsored TLD, e.g. `.edu`.
  - `:country_code` - Returns a country code TLD, e.g. `.id`.

  ## Examples

      iex> NeoFaker.Internet.tld()
      ".com"

      iex> NeoFaker.Internet.tld(dot: false)
      "org"

      iex> NeoFaker.Internet.tld(type: :safe)
      ".example"

      iex> NeoFaker.Internet.tld(type: :country_code)
      ".id"

  """
  @spec tld(Keyword.t()) :: String.t()
  def tld(opts \\ []) do
    type = Keyword.get(opts, :type, :all)

    if Keyword.get(opts, :dot, true) do
      "." <> TLD.name(type)
    else
      TLD.name(type)
    end
  end
end
