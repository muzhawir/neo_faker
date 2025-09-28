defmodule NeoFaker.Internet do
  @moduledoc """
  Functions for generating internet-related data.

  This module provides utilities to generate random internet-related information, such as email
  addresses, domain names, URLs, IP addresses, and MAC addresses.
  """
  @moduledoc since: "0.13.0"

  alias NeoFaker.Internet.Email
  alias NeoFaker.Internet.TLD
  alias NeoFaker.Internet.UserName

  @doc """
  Generates a random top-level domain (TLD).

  Returns a random TLD string.

  ## Options

  The accepted options are:

  - `:dot` - A boolean indicating whether to include a leading dot in the TLD. Defaults to `true`.
  - `:type` - Specifies the type of TLD to generate.

  The values for `:type` can be:

  - `:all_except_safe` - Returns a TLD from all types except safe TLDs. This is the default.
  - `:all` - Returns a TLD from all available types, including safe TLDs.
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
    type = Keyword.get(opts, :type, :all_except_safe)

    if Keyword.get(opts, :dot, true) do
      "." <> TLD.generate_name(type)
    else
      TLD.generate_name(type)
    end
  end

  @doc """
  Generates a random username.

  Returns a random username string.

  ## Options

  The accepted options are:

  - `:word_count` - Specifies the number of words to include in the username. Defaults to `2`.
  - `:separator` - Defines the separator to use between words in the username.
  - `:username_type` - Specifies the type of words to use in the username.
  - `:number` - A boolean indicating whether to append a random number to the username.
     Defaults to `false`.
  - `:number_range` - Defines the range of numbers to choose from when appending a number.
     Defaults to `1..1000`.

  The values for `:separator` can be:

  - `:all` - Uses any of the separators (default).
  - `:dot` - Uses a dot (`.`) as the separator.
  - `:underscore` - Uses an underscore (`_`) as the separator.
  - `:dash` - Uses a dash (`-`) as the separator.

  The values for `:username_type` can be:

  - `:person` - Uses random first or last names for the username, which is the default.
  - `:word` - Uses random words for the username.

  ## Examples

      iex> NeoFaker.Internet.user_name()
      "josé_valim"

      iex> NeoFaker.Internet.user_name(word_count: 3, separator: :dot)
      "abigail.bethany.crawford"

      iex> NeoFaker.Internet.user_name(username_type: :word, number: true, number_range: 1..2025)
      "elixir_alchemist_2012"

  """
  @spec user_name(Keyword.t()) :: String.t()
  def user_name(opts \\ []) do
    word_count = 1..Keyword.get(opts, :word_count, 2)
    separator = opts |> Keyword.get(:separator, :all) |> UserName.separator()

    base =
      Enum.map_join(word_count, separator, fn _ ->
        UserName.word(Keyword.get(opts, :username_type, :person))
      end)

    if Keyword.get(opts, :number, false) do
      base <> separator <> "#{Enum.random(Keyword.get(opts, :number_range, 1..1000))}"
    else
      base
    end
  end

  def email(opts \\ []) do
    user_name =
      user_name(
        Keyword.take(opts, [:word_count, :separator, :username_type, :number, :number_range])
      )

    domain_name = Email.generate_domain(Keyword.take(opts, [:name]))

    case Keyword.get(opts, :tld_type, :all_except_safe) do
      :all_except_safe ->
        user_name <> "@" <> domain_name <> tld(type: :all_except_safe)

      :all ->
        user_name <> "@" <> domain_name <> tld(type: :all)

      :safe ->
        user_name <> "@" <> domain_name <> tld(type: :safe)

      :generic ->
        user_name <> "@" <> domain_name <> tld(type: :generic)

      :sponsored ->
        user_name <> "@" <> domain_name <> tld(type: :sponsored)

      :country_code ->
        user_name <> "@" <> domain_name <> tld(type: :country_code)

      :popular ->
        user_name <> "@" <> Email.generate_domain(name: :popular)

      :custom ->
        domain_name =
          Email.generate_domain(
            name: :custom,
            domain_name: Keyword.get(opts, :custom_domain, "example.com")
          )

        user_name <> "@" <> domain_name

      _ ->
        user_name <> "@" <> domain_name <> tld(type: :all_except_safe)
    end
  end
end
