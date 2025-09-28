defmodule NeoFaker.Internet do
  @moduledoc """
  Functions for generating internet-related data.

  This module provides utilities to generate random internet-related information, such as email
  addresses, domain names, URLs, IP addresses, and MAC addresses.
  """
  @moduledoc since: "0.13.0"

  alias NeoFaker.Internet.Domain
  alias NeoFaker.Internet.Email
  alias NeoFaker.Internet.TLD
  alias NeoFaker.Internet.Username

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

  - `:person` - Uses random first or last names for the username (default).
  - `:word` - Uses random words for the username.

  ## Examples

      iex> NeoFaker.Internet.username()
      "josé_valim"

      iex> NeoFaker.Internet.username(word_count: 3, joiner: :dot)
      "abigail.bethany.crawford"

      iex> NeoFaker.Internet.username(username_type: :word, number: true, number_range: 1..2025)
      "elixir_alchemist_2012"

  """
  @spec username(Keyword.t()) :: String.t()
  def username(opts \\ []) do
    word_count = 1..Keyword.get(opts, :word_count, 2)
    joiner = opts |> Keyword.get(:joiner, :all) |> Username.joiner()

    base =
      Enum.map_join(word_count, joiner, fn _ ->
        Username.word(Keyword.get(opts, :username_type, :person))
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
  Generates a random email address.

  Returns a random email address string based on the specified options.

  ## Options

  ### Username Options

  The accepted options for username generation are:

  - `:word_count` - Specifies the number of words to include in the username. Defaults to `2`.
  - `:joiner` - Defines the joiner to use between words in the username.
  - `:username_type` - Specifies the type of words to use in the username.
  - `:number` - A boolean indicating whether to append a random number to the username.
    Defaults to `false`, if set to `true`, a number will be appended between `1` and `1000`, for
    define a custom range, use the `:number_range` option.
  - `:number_range` - Defines the range of numbers to choose from when appending a number.
    Defaults to `1..1000`.

  The values for `:joiner` can be:

  - `:all` - Uses any of the joiners (default).
  - `:dot` - Uses a dot (`.`) as the joiner.
  - `:underscore` - Uses an underscore (`_`) as the joiner.
  - `:dash` - Uses a dash (`-`) as the joiner.

  The values for `:username_type` can be:

  - `:person` - Uses random first or last names for the username (default).
  - `:word` - Uses random words for the username.

  ### Domain Name Options

  The accepted options for domain name generation are:

  - `:word_count` - Specifies the number of words to include in the domain name. Defaults to `1`.
  - `:domain_type` - Specifies the type of domain name to generate.
  - `:popular_type` - When `:domain_type` is set to `:popular`, this option defines the category
    of popular domains to select from. Defaults to `:all`.
  - `:domain_name` - When `:domain_type` is set to `:custom`, this option allows the user to
    provide a custom domain name. If not provided, defaults to "example.com".

  The values for `:domain_type` can be:

  - `:random` - Generates a random domain name using a random word (default).
  - `:popular` - Selects a domain name from a list of popular domains, with the specific category
    defined by the `:popular_type` option. For this option, the output will be a full domain name
    like "gmail.com".
  - `:custom` - Uses a custom domain name provided by the user via the `:domain_name` option. If
    not provided, defaults to "example.com".

  If `:domain_type` is set to `:popular`, the `:popular_type` option can be used to specify the
  category of popular domains to select from. The values for `:popular_type` can be:

  - `:all` - Selects from all popular domains (default).
  - `:ecommerce` - Selects from popular e-commerce domains.
  - `:email` - Selects from popular email service domains.
  - `:search` - Selects from popular search engine domains.
  - `:social` - Selects from popular social media domains.

  ### TLD Options

  The accepted options for TLD generation are:

  - `:dot` - A boolean indicating whether to include a leading dot in the TLD. Defaults to `true`.
  - `:tld_type` - Specifies the type of TLD to generate.

  The values for `:tld_type` can be:

  - `:all_except_safe` - Returns a TLD from all types except safe TLDs. This is the default.
  - `:all` - Returns a TLD from all available types, including safe TLDs.
  - `:safe` - Returns a safe TLD, e.g. `.example`.
  - `:generic` - Returns a generic TLD, e.g. `.com`.
  - `:sponsored` - Returns a sponsored TLD, e.g. `.edu`.
  - `:country_code` - Returns a country code TLD, e.g. `.id`.

  ## Examples

      iex> NeoFaker.Internet.email()
      "josé@example.com"

      iex> NeoFaker.Internet.email(word_count: 3, joiner: :dot, number: true)
      "abigail.bethany.crawford_202"

      iex> NeoFaker.Internet.email(domain_type: :popular, popular_type: :email)
      "jane.doe@gmail.com"

      iex> NeoFaker.Internet.email(domain_type: :custom, domain_name: "elixir-lang.org")
      "josé@elixir-lang.org"

      iex> NeoFaker.Internet.email(tld_type: :country_code, dot: false)
      "josé@example.id"

  """
  @spec email(Keyword.t()) :: String.t()
  def email(opts \\ []) do
    username = Email.generate_username(opts)
    domain_name = Email.generate_domain_name(opts)
    tld = Email.generate_tld(opts)

    if Keyword.get(opts, :domain_type, :random) in [:popular, :custom] do
      "#{username}@#{domain_name}"
    else
      "#{username}@#{domain_name}#{tld}"
    end
  end

  @doc """
  Generates a random IPv4 address.

  Returns a random IPv4 address string.

  ## Examples

      iex> NeoFaker.Internet.ipv4()
      "183.235.34.108"

  """
  @spec ipv4() :: String.t()
  def ipv4, do: Enum.map_join(1..4, ".", fn _ -> :rand.uniform(255) - 1 end)

  @doc """
  Generates a random IPv6 address.

  Returns a random IPv6 address string.

  ## Options

  The accepted options are:

  - `:uppercase` - A boolean indicating whether to return the address in uppercase.
    Defaults to `true`.

  ## Examples

      iex> NeoFaker.Internet.ipv6()
      "E0E6:7E24:EC6E:E44C:FC69:9C25:CD85:CE08"

      iex> NeoFaker.Internet.ipv6(uppercase: false)
      "e0e6:7e24:ec6e:e44c:fc69:9c25:cd85:ce08"

  """
  @spec ipv6(Keyword.t()) :: String.t()
  def ipv6(opts \\ []) do
    ip_address =
      Enum.map_join(1..8, ":", fn _ ->
        Integer.to_string(:rand.uniform(0xFFFF) - 1, 16)
      end)

    if Keyword.get(opts, :uppercase, true) do
      String.upcase(ip_address)
    else
      String.downcase(ip_address)
    end
  end

  @doc """
  Generates a random MAC address.

  Returns a random MAC address string.

  ## Options

  The accepted options are:

  - `:uppercase` - A boolean indicating whether to return the MAC address in uppercase.
    Defaults to `true`.

  ## Examples

      iex> NeoFaker.Internet.mac_address()
      "74:4E:44:B0:D0:93"

      iex> NeoFaker.Internet.mac_address(uppercase: false)
      "74:4e:44:b0:d0:93"

  """
  @spec mac_address(Keyword.t()) :: String.t()
  def mac_address(opts \\ []) do
    mac_address =
      Enum.map_join(1..6, ":", fn _ ->
        (:rand.uniform(0xFF) - 1)
        |> Integer.to_string(16)
        |> String.pad_leading(2, "0")
      end)

    if Keyword.get(opts, :uppercase, true) do
      String.upcase(mac_address)
    else
      String.downcase(mac_address)
    end
  end
end
