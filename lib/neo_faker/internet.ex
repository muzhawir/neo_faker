defmodule NeoFaker.Internet do
  @moduledoc """
  Functions for generating internet-related data.

  This module provides utilities to generate random internet-related information, such as email
  addresses, domain names, URLs, IP addresses, and MAC addresses.
  """
  @moduledoc since: "0.13.0"

  alias NeoFaker.Internet.Domain
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
  - `:joiner` - Defines the joiner to use between words in the username.
  - `:username_type` - Specifies the type of words to use in the username.
  - `:number` - A boolean indicating whether to append a random number to the username.
     Defaults to `false`.
  - `:number_range` - Defines the range of numbers to choose from when appending a number.
     Defaults to `1..1000`.

  The values for `:joiner` can be:

  - `:all` - Uses any of the joiners (default).
  - `:dot` - Uses a dot (`.`) as the joiner.
  - `:underscore` - Uses an underscore (`_`) as the joiner.
  - `:dash` - Uses a dash (`-`) as the joiner.

  The values for `:username_type` can be:

  - `:person` - Uses random first or last names for the username, which is the default.
  - `:word` - Uses random words for the username.

  ## Examples

      iex> NeoFaker.Internet.user_name()
      "josé_valim"

      iex> NeoFaker.Internet.user_name(word_count: 3, joiner: :dot)
      "abigail.bethany.crawford"

      iex> NeoFaker.Internet.user_name(username_type: :word, number: true, number_range: 1..2025)
      "elixir_alchemist_2012"

  """
  @spec user_name(Keyword.t()) :: String.t()
  def user_name(opts \\ []) do
    word_count = 1..Keyword.get(opts, :word_count, 2)
    joiner = opts |> Keyword.get(:joiner, :all) |> UserName.joiner()

    base =
      Enum.map_join(word_count, joiner, fn _ ->
        UserName.word(Keyword.get(opts, :username_type, :person))
      end)

    if Keyword.get(opts, :number, false) do
      base <> joiner <> "#{Enum.random(Keyword.get(opts, :number_range, 1..1000))}"
    else
      base
    end
  end

  @doc """
  Generates a random domain name.

  Returns a random domain name string based on the specified options.

  ## Options

  The accepted options are:

  - `:word_count` - Specifies the number of words to include in the domain name. Defaults to `1`.
  - `:type` - Specifies the type of domain name to generate.

  The values for `:type` can be:

  - `:random` - Generates a random domain name using a random word (default).
  - `:popular` - Selects a domain name from a list of popular domains, with the specific category
    defined by the `:popular_type` option. For this option, the output will be a full domain name
    like "gmail.com".
  - `:custom` - Uses a custom domain name provided by the user via the `:domain_name` option. If
    not provided, defaults to "example.com".

  If `:type` is set to `:popular`, the `:popular_type` option can be used to specify the category
  of popular domains to select from. The values for `:popular_type` can be:

  - `:all` - Selects from all popular domains (default).
  - `:ecommerce` - Selects from popular e-commerce domains.
  - `:email` - Selects from popular email service domains.
  - `:search` - Selects from popular search engine domains.
  - `:social` - Selects from popular social media domains.

  ## Examples

      iex> NeoFaker.Internet.domain_name()
      "example"

      iex> NeoFaker.Internet.domain_name(word_count: 3)
      "alpha-beta-gamma"

      iex> NeoFaker.Internet.domain_name(type: :popular, popular_type: :email)
      "gmail.com"

      iex> NeoFaker.Internet.domain_name(type: :custom, domain_name: "elixir-lang.org")
      "elixir-lang.org"

  """
  @spec domain_name(keyword()) :: String.t()
  def domain_name(opts \\ []) do
    word_count = Keyword.get(opts, :word_count, 1)

    case Keyword.get(opts, :type, :random) do
      :random ->
        Enum.map_join(1..word_count, "-", fn _ -> String.downcase(NeoFaker.Text.word()) end)

      :popular ->
        Domain.generate_popular_domain_name(Keyword.get(opts, :popular_type, :all))

      :custom ->
        Keyword.get(opts, :domain_name, "example.com")

      _ ->
        String.downcase(NeoFaker.Text.word())
    end
  end

  @spec email(Keyword.t()) :: String.t()
  def email(opts \\ []) do
    user_name =
      user_name(
        Keyword.take(opts, [:word_count, :joiner, :username_type, :number, :number_range])
      )

    domain_name = domain_name(Keyword.take(opts, [:type, :popular_type, :domain_name, :dot]))

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
        user_name <> "@" <> domain_name(type: :popular)

      :custom ->
        domain_name =
          domain_name(
            name: :custom,
            domain_name: Keyword.get(opts, :custom_domain, "example.com")
          )

        user_name <> "@" <> domain_name

      _ ->
        user_name <> "@" <> domain_name <> tld(type: :all_except_safe)
    end
  end
end
