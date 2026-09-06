defmodule NeoFaker.Internet do
  @moduledoc """
  Functions for generating internet-related data.

  Provides utilities to generate random usernames, email addresses, domain names, URLs,
  IP addresses, MAC addresses, and slugs with flexible formatting and validation options.
  """
  @moduledoc since: "0.13.0"

  alias NeoFaker.Helpers.Formatter
  alias NeoFaker.Helpers.Options
  alias NeoFaker.Internet.DomainGenerator
  alias NeoFaker.Internet.EmailGenerator
  alias NeoFaker.Internet.Generator
  alias NeoFaker.Internet.TldGenerator
  alias NeoFaker.Internet.UsernameGenerator

  @username_schema NimbleOptions.new!(
                     word_count: [type: :pos_integer, default: 2],
                     joiner: [type: {:in, [:all, :dot, :underscore, :dash]}, default: :all],
                     username_type: [type: {:in, [:person, :word]}, default: :person],
                     number: [type: :boolean, default: false],
                     number_range: [type: {:struct, Range}, default: 1..1000]
                   )

  @domain_name_schema NimbleOptions.new!(
                        word_count: [type: :pos_integer, default: 1],
                        type: [type: {:in, [:random, :popular, :custom]}, default: :random],
                        popular_type: [
                          type: {:in, [:all, :ecommerce, :email, :search, :social]},
                          default: :all
                        ],
                        domain_name: [type: :string, default: "example.com"]
                      )

  @tld_schema NimbleOptions.new!(
                dot: [type: :boolean, default: true],
                type: [
                  type:
                    {:in, [:all_except_safe, :all, :safe, :generic, :sponsored, :country_code]},
                  default: :all_except_safe
                ]
              )

  @email_schema NimbleOptions.new!(
                  username_word_count: [type: :pos_integer, default: 2],
                  joiner: [type: {:in, [:all, :dot, :underscore, :dash]}, default: :all],
                  username_type: [type: {:in, [:person, :word]}, default: :person],
                  number: [type: :boolean, default: false],
                  number_range: [type: {:struct, Range}, default: 1..1000],
                  domain_name_word_count: [type: :pos_integer, default: 1],
                  domain_type: [type: {:in, [:random, :popular, :custom]}, default: :random],
                  popular_type: [
                    type: {:in, [:all, :ecommerce, :email, :search, :social]},
                    default: :all
                  ],
                  domain_name: [type: :string, default: "example.com"],
                  tld_type: [
                    type:
                      {:in, [:all_except_safe, :all, :safe, :generic, :sponsored, :country_code]},
                    default: :all_except_safe
                  ]
                )

  @ipv4_schema NimbleOptions.new!(
                 private: [type: :boolean, default: false],
                 class: [type: {:or, [nil, {:in, [:a, :b, :c]}]}, default: nil]
               )

  @ipv6_schema NimbleOptions.new!(
                 uppercase: [type: :boolean, default: true],
                 compressed: [type: :boolean, default: false]
               )

  @mac_address_schema NimbleOptions.new!(
                        uppercase: [type: :boolean, default: true],
                        separator: [type: {:in, [":", "-", ""]}, default: ":"]
                      )

  @url_schema NimbleOptions.new!(
                protocol: [type: {:in, [:http, :https]}, default: :https],
                domain_type: [type: {:in, [:random, :popular, :custom]}, default: :random],
                path: [type: :boolean, default: false],
                query: [type: :boolean, default: false],
                word_count: [type: :pos_integer, default: 1],
                popular_type: [
                  type: {:in, [:all, :ecommerce, :email, :search, :social]},
                  default: :all
                ],
                domain_name: [type: :string, default: "example.com"]
              )

  @slug_schema NimbleOptions.new!(separator: [type: :string, default: "-"])

  @doc """
  Generates a random username.

  Returns a username string composed of words joined by a separator, with an optional
  numeric suffix.

  ## Options

    * `:word_count` (positive integer) - the number of words in the username. Defaults
      to `2`.
    * `:joiner` (`:all`, `:dot`, `:underscore`, or `:dash`) - the separator between words.
      `:all` picks any of the available joiners at random. Defaults to `:all`.
    * `:username_type` (`:person` or `:word`) - the word source. `:person` draws from random
      first or last names; `:word` draws from random words. Defaults to `:person`.
    * `:number` (boolean) - when `true`, appends a random number. Defaults to `false`.
    * `:number_range` (`Range`) - the range to sample the appended number from. Defaults
      to `1..1000`.

  ## Examples

      iex> NeoFaker.Internet.username()
      "josé_valim"

      iex> NeoFaker.Internet.username(word_count: 3, joiner: :dot)
      "abigail.bethany.crawford"

      iex> NeoFaker.Internet.username(username_type: :word, number: true, number_range: 1..2025)
      "elixir_alchemist_2012"

      iex> NeoFaker.Internet.username(number: true)
      "jane_smith_42"

  """
  @spec username(keyword()) :: String.t()
  def username(opts \\ []) do
    opts = Options.validate!(opts, @username_schema)
    joiner = UsernameGenerator.joiner(Keyword.fetch!(opts, :joiner))

    base =
      Enum.map_join(1..Keyword.fetch!(opts, :word_count), joiner, fn _ ->
        UsernameGenerator.word(Keyword.fetch!(opts, :username_type))
      end)

    if Keyword.fetch!(opts, :number) do
      base <> joiner <> "#{Enum.random(Keyword.fetch!(opts, :number_range))}"
    else
      base
    end
  end

  @doc """
  Generates a random domain name.

  Returns a domain name string based on the specified type. Can produce random
  word-based names, popular real-world domains, or a user-supplied custom domain.

  ## Options

    * `:word_count` (positive integer) - the number of words in a random domain name.
      Defaults to `1`.
    * `:type` (`:random`, `:popular`, or `:custom`) - the domain name strategy. Defaults
      to `:random`.
      * `:random` - a random word-based domain name.
      * `:popular` - a domain name from a list of popular real-world domains.
      * `:custom` - the user-supplied domain name given via `:domain_name`.
    * `:popular_type` (`:all`, `:ecommerce`, `:email`, `:search`, or `:social`) - the popular
      domain category, used when `:type` is `:popular`. Defaults to `:all`.
    * `:domain_name` (string) - the custom domain, used when `:type` is `:custom`. Defaults
      to `"example.com"`.

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
    opts = Options.validate!(opts, @domain_name_schema)

    case Keyword.fetch!(opts, :type) do
      :random ->
        Enum.map_join(1..Keyword.fetch!(opts, :word_count), "-", fn _ ->
          String.downcase(NeoFaker.Text.word())
        end)

      :popular ->
        DomainGenerator.generate_popular_domain_name(Keyword.fetch!(opts, :popular_type))

      :custom ->
        custom_domain = Keyword.fetch!(opts, :domain_name)

        if custom_domain == "" do
          raise ArgumentError,
                "Invalid :domain_name #{inspect(custom_domain)}. Expected a non-empty string, " <>
                  "e.g. \"example.com\"."
        else
          custom_domain
        end
    end
  end

  @doc """
  Generates a random top-level domain (TLD).

  Returns a TLD string, with a leading dot by default.

  ## Options

    * `:dot` (boolean) - when `false`, omits the leading dot. Defaults to `true`.
    * `:type` (an atom below) - the TLD category. Defaults to `:all_except_safe`.
      * `:all_except_safe` - all TLD categories except safe TLDs.
      * `:all` - all TLD categories, including safe TLDs.
      * `:safe` - safe TLDs, e.g. `.example`.
      * `:generic` - generic TLDs, e.g. `.com`.
      * `:sponsored` - sponsored TLDs, e.g. `.edu`.
      * `:country_code` - country code TLDs, e.g. `.id`.

  ## Examples

      iex> NeoFaker.Internet.tld()
      ".com"

      iex> NeoFaker.Internet.tld(dot: false)
      "org"

      iex> NeoFaker.Internet.tld(type: :safe)
      ".example"

      iex> NeoFaker.Internet.tld(type: :generic, dot: false)
      "net"

  """
  @spec tld(keyword()) :: String.t()
  def tld(opts \\ []) do
    opts = Options.validate!(opts, @tld_schema)
    tld_name = TldGenerator.generate_name(Keyword.fetch!(opts, :type))

    if Keyword.fetch!(opts, :dot) do
      "." <> tld_name
    else
      tld_name
    end
  end

  @doc """
  Generates a random email address.

  Combines username, domain name, and TLD generation into a single email address string.
  Accepts all the same options as `username/1`, `domain_name/1`, and `tld/1`, each prefixed
  by its context below.

  ## Username options

    * `:username_word_count` (positive integer) - the number of words in the username.
      Defaults to `2`.
    * `:joiner` (`:all`, `:dot`, `:underscore`, or `:dash`) - the separator between username
      words. Defaults to `:all`.
    * `:username_type` (`:person` or `:word`) - the word source. Defaults to `:person`.
    * `:number` (boolean) - when `true`, appends a random number to the username. Defaults
      to `false`.
    * `:number_range` (`Range`) - the range for the appended number. Defaults to `1..1000`.

  ## Domain name options

    * `:domain_name_word_count` (positive integer) - the number of words in the domain name.
      Defaults to `1`.
    * `:domain_type` (`:random`, `:popular`, or `:custom`) - the domain name strategy.
      Defaults to `:random`.
    * `:popular_type` (`:all`, `:ecommerce`, `:email`, `:search`, or `:social`) - the popular
      domain category, used when `:domain_type` is `:popular`. Defaults to `:all`.
    * `:domain_name` (string) - the custom domain, used when `:domain_type` is `:custom`.
      Defaults to `"example.com"`.

  ## TLD options

    * `:tld_type` (an atom accepted by `tld/1`'s `:type` option) - the TLD category.
      Defaults to `:all_except_safe`.

  ## Examples

      iex> NeoFaker.Internet.email()
      "josé@example.com"

      iex> NeoFaker.Internet.email(username_word_count: 3, joiner: :dot, number: true)
      "abigail.bethany.crawford_202@example.com"

      iex> NeoFaker.Internet.email(domain_type: :popular, popular_type: :email)
      "jane.doe@gmail.com"

      iex> NeoFaker.Internet.email(domain_type: :custom, domain_name: "elixir-lang.org")
      "josé@elixir-lang.org"

  """
  @spec email(keyword()) :: String.t()
  def email(opts \\ []) do
    opts = Options.validate!(opts, @email_schema)

    username = EmailGenerator.generate_username(opts)
    domain_name = EmailGenerator.generate_domain_name(opts)
    tld = EmailGenerator.generate_tld(opts)

    if Keyword.fetch!(opts, :domain_type) in [:popular, :custom] do
      "#{username}@#{domain_name}"
    else
      "#{username}@#{domain_name}#{tld}"
    end
  end

  @doc """
  Generates a random IPv4 address.

  Returns a dotted-decimal IPv4 address string.

  ## Options

    * `:private` (boolean) - when `true`, generates an address from an RFC 1918 private
      range instead of a public one. Defaults to `false`.
    * `:class` (`:a`, `:b`, `:c`, or `nil`) - the private IP class, used when `:private` is
      `true`. Defaults to `nil` (randomly selected).
      * `:a` - Class A range (`10.0.0.0/8`).
      * `:b` - Class B range (`172.16.0.0/12`).
      * `:c` - Class C range (`192.168.0.0/16`).

  ## Examples

      iex> NeoFaker.Internet.ipv4()
      "183.235.34.108"

      iex> NeoFaker.Internet.ipv4(private: true)
      "192.168.1.42"

      iex> NeoFaker.Internet.ipv4(private: true, class: :a)
      "10.25.30.100"

  """
  @spec ipv4(keyword()) :: String.t()
  def ipv4(opts \\ []) do
    opts = Options.validate!(opts, @ipv4_schema)

    if Keyword.fetch!(opts, :private) do
      class = Keyword.fetch!(opts, :class) || Enum.random([:a, :b, :c])
      Generator.private_ipv4(class)
    else
      Generator.public_ipv4()
    end
  end

  @doc """
  Generates a random IPv6 address.

  Returns a colon-separated hexadecimal IPv6 address string.

  ## Options

    * `:uppercase` (boolean) - when `false`, returns the address in lowercase. Defaults
      to `true`.
    * `:compressed` (boolean) - when `true`, uses compressed `::` notation. Defaults
      to `false`.

  ## Examples

      iex> NeoFaker.Internet.ipv6()
      "E0E6:7E24:EC6E:E44C:FC69:9C25:CD85:CE08"

      iex> NeoFaker.Internet.ipv6(uppercase: false)
      "e0e6:7e24:ec6e:e44c:fc69:9c25:cd85:ce08"

      iex> NeoFaker.Internet.ipv6(compressed: true)
      "2001:db8::8a2e:370:7334"

  """
  @spec ipv6(keyword()) :: String.t()
  def ipv6(opts \\ []) do
    opts = Options.validate!(opts, @ipv6_schema)

    ip_address =
      if Keyword.fetch!(opts, :compressed) do
        Generator.compressed_ipv6()
      else
        Enum.map_join(1..8, ":", fn _ ->
          (:rand.uniform(0x10_000) - 1)
          |> Integer.to_string(16)
          |> String.pad_leading(4, "0")
        end)
      end

    Formatter.apply_case(
      ip_address,
      if(Keyword.fetch!(opts, :uppercase), do: :upper, else: :lower)
    )
  end

  @doc """
  Generates a random MAC address.

  Returns a hexadecimal MAC address string with configurable separator and casing.

  ## Options

    * `:uppercase` (boolean) - when `false`, returns the address in lowercase. Defaults
      to `true`.
    * `:separator` (`":"`, `"-"`, or `""`) - the separator between octets. Defaults to `":"`.

  ## Examples

      iex> NeoFaker.Internet.mac_address()
      "74:4E:44:B0:D0:93"

      iex> NeoFaker.Internet.mac_address(uppercase: false)
      "74:4e:44:b0:d0:93"

      iex> NeoFaker.Internet.mac_address(separator: "-")
      "74-4E-44-B0-D0-93"

      iex> NeoFaker.Internet.mac_address(separator: "", uppercase: false)
      "744e44b0d093"

  """
  @spec mac_address(keyword()) :: String.t()
  def mac_address(opts \\ []) do
    opts = Options.validate!(opts, @mac_address_schema)

    mac_address =
      Enum.map_join(1..6, Keyword.fetch!(opts, :separator), fn _ ->
        (:rand.uniform(0x100) - 1)
        |> Integer.to_string(16)
        |> String.pad_leading(2, "0")
      end)

    Formatter.apply_case(
      mac_address,
      if(Keyword.fetch!(opts, :uppercase), do: :upper, else: :lower)
    )
  end

  @doc """
  Generates a random URL.

  Returns a URL string built from a protocol, domain name, and TLD. Optionally
  appends a random path and/or query string.

  ## Options

    * `:protocol` (`:https` or `:http`) - the URL scheme. Defaults to `:https`.
    * `:domain_type` (`:random`, `:popular`, or `:custom`) - the domain name strategy, as in
      `domain_name/1`. Defaults to `:random`.
    * `:path` (boolean) - when `true`, appends a random path. Defaults to `false`.
    * `:query` (boolean) - when `true`, appends random query parameters. Defaults to `false`.

  ## Examples

      iex> NeoFaker.Internet.url()
      "https://example.com"

      iex> NeoFaker.Internet.url(protocol: :http)
      "http://neo-faker.org"

      iex> NeoFaker.Internet.url(path: true)
      "https://example.com/users/profile"

      iex> NeoFaker.Internet.url(path: true, query: true)
      "https://example.com/api/v1?key=value&id=123"

  """
  @spec url(keyword()) :: String.t()
  def url(opts \\ []) do
    opts = Options.validate!(opts, @url_schema)

    domain_opts =
      opts
      |> Keyword.take([:word_count, :popular_type, :domain_name])
      |> Keyword.put(:type, Keyword.fetch!(opts, :domain_type))

    domain = domain_name(domain_opts)

    # For :popular and :custom the domain is already fully-qualified (e.g.
    # "gmail.com"), so appending a TLD would produce "gmail.com.net". Only
    # word-based (:random) domains need a TLD appended.
    base_url =
      if Keyword.fetch!(opts, :domain_type) == :random do
        "#{Keyword.fetch!(opts, :protocol)}://#{domain}#{tld()}"
      else
        "#{Keyword.fetch!(opts, :protocol)}://#{domain}"
      end

    url_with_path =
      if Keyword.fetch!(opts, :path) do
        "#{base_url}/#{Generator.url_path()}"
      else
        base_url
      end

    if Keyword.fetch!(opts, :query) do
      "#{url_with_path}?#{Generator.query_string()}"
    else
      url_with_path
    end
  end

  @doc """
  Generates a random URL-friendly slug.

  Returns a lowercase, word-joined string suitable for use in URLs. `word_count` sets the
  number of words and defaults to `3`.

  ## Options

    * `:separator` (string) - the separator between words. Defaults to `"-"`.

  ## Examples

      iex> NeoFaker.Internet.slug()
      "neo-faker-elixir"

      iex> NeoFaker.Internet.slug(5)
      "the-quick-brown-fox-jumps"

      iex> NeoFaker.Internet.slug(2, separator: "_")
      "hello_world"

  """
  @spec slug(pos_integer(), keyword()) :: String.t()
  def slug(word_count \\ 3, opts \\ []) when is_integer(word_count) and word_count > 0 do
    opts = Options.validate!(opts, @slug_schema)

    Enum.map_join(1..word_count, Keyword.fetch!(opts, :separator), fn _ ->
      String.downcase(NeoFaker.Text.word())
    end)
  end
end
