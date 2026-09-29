defmodule NeoFaker.Internet do
  @moduledoc """
  Functions for generating internet identifiers.

  Covers usernames, email addresses, domain names, top-level domains, URLs, slugs, and
  IPv4, IPv6, and MAC addresses.

  Generated words are reduced to lowercase ASCII letters and digits before they are
  used, so usernames, domain labels, and slugs only ever contain the separators this
  module inserts.
  """
  @moduledoc since: "0.13.0"

  alias NeoFaker.Helpers.Formatter
  alias NeoFaker.Helpers.Validator
  alias NeoFaker.Internet.DomainGenerator
  alias NeoFaker.Internet.EmailGenerator
  alias NeoFaker.Internet.Generator
  alias NeoFaker.Internet.TldGenerator
  alias NeoFaker.Internet.UsernameGenerator
  alias NeoFaker.Internet.Validator, as: InternetValidator
  alias NeoFaker.Text

  @joiners [:all, :dot, :underscore, :dash]
  @username_types [:person, :word]
  @domain_types [:random, :popular, :custom]
  @popular_types [:all, :ecommerce, :email, :search, :social]
  @tld_types [:all_except_safe, :all, :safe, :generic, :sponsored, :country_code]

  @number_range [type: {:custom, Validator, :validate_range_option, []}, default: 1..1000]
  @domain_name [
    type: {:custom, InternetValidator, :validate_domain_name, []},
    default: "example.com"
  ]

  @username_schema NimbleOptions.new!(
                     word_count: [type: :pos_integer, default: 2],
                     joiner: [type: {:in, @joiners}, default: :all],
                     username_type: [type: {:in, @username_types}, default: :person],
                     number: [type: :boolean, default: false],
                     number_range: @number_range
                   )

  @domain_name_schema NimbleOptions.new!(
                        word_count: [type: :pos_integer, default: 1],
                        type: [type: {:in, @domain_types}, default: :random],
                        popular_type: [type: {:in, @popular_types}, default: :all],
                        domain_name: @domain_name
                      )

  @tld_schema NimbleOptions.new!(
                dot: [type: :boolean, default: true],
                type: [type: {:in, @tld_types}, default: :all_except_safe]
              )

  @email_schema NimbleOptions.new!(
                  username_word_count: [type: :pos_integer, default: 2],
                  joiner: [type: {:in, @joiners}, default: :all],
                  username_type: [type: {:in, @username_types}, default: :person],
                  number: [type: :boolean, default: false],
                  number_range: @number_range,
                  domain_name_word_count: [type: :pos_integer, default: 1],
                  domain_type: [type: {:in, @domain_types}, default: :random],
                  popular_type: [type: {:in, @popular_types}, default: :all],
                  domain_name: @domain_name,
                  tld_type: [type: {:in, @tld_types}, default: :all_except_safe]
                )

  @ipv4_schema NimbleOptions.new!(
                 private: [type: :boolean, default: false],
                 class: [type: {:in, [nil, :a, :b, :c]}, default: nil]
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
                domain_type: [type: {:in, @domain_types}, default: :random],
                word_count: [type: :pos_integer, default: 1],
                popular_type: [type: {:in, @popular_types}, default: :all],
                domain_name: @domain_name,
                path: [type: :boolean, default: false],
                query: [type: :boolean, default: false]
              )

  @slug_schema NimbleOptions.new!(separator: [type: :string, default: "-"])

  @doc """
  Generates a random username.

  The username is made of lowercase words joined by a single separator, optionally
  followed by a number with the same separator.

  ## Options

    * `:word_count` (positive integer) - the number of words. Defaults to `2`.
    * `:joiner` (`:all`, `:dot`, `:underscore`, or `:dash`) - the separator between
      words: `"."`, `"_"`, or `"-"`. `:all` picks one of the three for each username.
      Defaults to `:all`.
    * `:username_type` (`:person` or `:word`) - `:person` builds the username from first
      and last names; `:word` builds it from common English words. Defaults to `:person`.
    * `:number` (boolean) - whether to append a number. Defaults to `false`.
    * `:number_range` (non-empty `Range`) - the range the appended number is drawn from.
      Requires `number: true`. Defaults to `1..1000`.

  ## Examples

      iex> NeoFaker.Internet.username()
      "jose_valim"

      iex> NeoFaker.Internet.username(word_count: 3, joiner: :dot)
      "abigail.bethany.crawford"

      iex> NeoFaker.Internet.username(username_type: :word, number: true, joiner: :dash)
      "elixir-alchemist-512"

  """
  @spec username(keyword()) :: String.t()
  def username(opts \\ []) do
    opts =
      opts
      |> NimbleOptions.validate!(@username_schema)
      |> InternetValidator.validate_requires!(opts, :number_range, :number)

    UsernameGenerator.username(
      Keyword.fetch!(opts, :word_count),
      Keyword.fetch!(opts, :joiner),
      Keyword.fetch!(opts, :username_type),
      if(Keyword.fetch!(opts, :number), do: Keyword.fetch!(opts, :number_range))
    )
  end

  @doc """
  Generates a random domain name.

  ## Options

    * `:type` (`:random`, `:popular`, or `:custom`) - how the domain is chosen. Defaults
      to `:random`.
      * `:random` - lowercase words joined by `"-"`, without a TLD, such as `"alpha-beta"`.
        Append one with `tld/1`.
      * `:popular` - a real, well-known domain with its TLD, such as `"gmail.com"`.
      * `:custom` - the value of `:domain_name`, returned verbatim.
    * `:word_count` (positive integer) - the number of words, for `type: :random`.
      Defaults to `1`.
    * `:popular_type` (`:all`, `:ecommerce`, `:email`, `:search`, or `:social`) - the
      category of domain, for `type: :popular`. Defaults to `:all`.
    * `:domain_name` (non-empty string) - the domain to return, for `type: :custom`.
      Defaults to `"example.com"`.

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
    opts = NimbleOptions.validate!(opts, @domain_name_schema)

    case Keyword.fetch!(opts, :type) do
      :random -> random_words(Keyword.fetch!(opts, :word_count), "-")
      :popular -> DomainGenerator.popular(Keyword.fetch!(opts, :popular_type))
      :custom -> Keyword.fetch!(opts, :domain_name)
    end
  end

  @doc """
  Generates a random top-level domain (TLD).

  ## Options

    * `:dot` (boolean) - whether to include the leading dot. Defaults to `true`.
    * `:type` (an atom below) - the TLD category. Defaults to `:all_except_safe`.
      * `:all_except_safe` - every registrable TLD: generic, sponsored, and country code.
      * `:all` - every TLD, including the reserved ones listed under `:safe`.
      * `:safe` - TLDs reserved for testing and documentation (RFC 2606), such as
        `.example` and `.test`, which never resolve on the public internet.
      * `:generic` - generic TLDs, such as `.com`.
      * `:sponsored` - sponsored TLDs, such as `.edu`.
      * `:country_code` - country code TLDs, such as `.id`.

  ## Examples

      iex> NeoFaker.Internet.tld()
      ".com"

      iex> NeoFaker.Internet.tld(dot: false)
      "org"

      iex> NeoFaker.Internet.tld(type: :safe)
      ".example"

  """
  @spec tld(keyword()) :: String.t()
  def tld(opts \\ []) do
    opts = NimbleOptions.validate!(opts, @tld_schema)
    name = TldGenerator.name(Keyword.fetch!(opts, :type))

    if Keyword.fetch!(opts, :dot), do: "." <> name, else: name
  end

  @doc """
  Generates a random email address.

  Combines `username/1`, `domain_name/1`, and `tld/1`. The options below are forwarded
  to those functions; some are renamed with a prefix so that they do not collide. A TLD
  is only appended to `:random` domains, since `:popular` and `:custom` domains already
  include one.

  ## Username options

    * `:username_word_count` (positive integer) - the number of words in the username.
      Defaults to `2`.
    * `:joiner` (`:all`, `:dot`, `:underscore`, or `:dash`) - the separator between
      username words. Defaults to `:all`.
    * `:username_type` (`:person` or `:word`) - the source of the username words.
      Defaults to `:person`.
    * `:number` (boolean) - whether to append a number to the username. Defaults to
      `false`.
    * `:number_range` (non-empty `Range`) - the range the appended number is drawn from.
      Requires `number: true`. Defaults to `1..1000`.

  ## Domain name options

    * `:domain_type` (`:random`, `:popular`, or `:custom`) - how the domain is chosen,
      as the `:type` option of `domain_name/1`. Defaults to `:random`.
    * `:domain_name_word_count` (positive integer) - the number of words in a random
      domain. Defaults to `1`.
    * `:popular_type` (`:all`, `:ecommerce`, `:email`, `:search`, or `:social`) - the
      category of a popular domain. Defaults to `:all`.
    * `:domain_name` (non-empty string) - the domain for `domain_type: :custom`.
      Defaults to `"example.com"`.

  ## TLD options

    * `:tld_type` - the TLD category, as the `:type` option of `tld/1`. Defaults to
      `:all_except_safe`.

  ## Examples

      iex> NeoFaker.Internet.email()
      "jose.valim@kappa.com"

      iex> NeoFaker.Internet.email(joiner: :dot, number: true)
      "jane.smith.202@lambda.net"

      iex> NeoFaker.Internet.email(domain_type: :popular, popular_type: :email)
      "jane-doe@gmail.com"

      iex> NeoFaker.Internet.email(domain_type: :custom, domain_name: "elixir-lang.org")
      "jose_valim@elixir-lang.org"

  """
  @spec email(keyword()) :: String.t()
  def email(opts \\ []) do
    opts =
      opts
      |> NimbleOptions.validate!(@email_schema)
      |> InternetValidator.validate_requires!(opts, :number_range, :number)

    username = EmailGenerator.generate_username(opts)
    domain_name = EmailGenerator.generate_domain_name(opts)

    case Keyword.fetch!(opts, :domain_type) do
      :random -> "#{username}@#{domain_name}#{EmailGenerator.generate_tld(opts)}"
      qualified when qualified in [:popular, :custom] -> "#{username}@#{domain_name}"
    end
  end

  @doc """
  Generates a random IPv4 address in dotted-decimal notation.

  By default the address is publicly routable: it never falls in a private, loopback,
  link-local, documentation, benchmarking, multicast, or other special-purpose block
  from the [IANA registry](https://www.iana.org/assignments/iana-ipv4-special-registry/).

  ## Options

    * `:private` (boolean) - when `true`, returns an address from a private range
      (RFC 1918) instead. Defaults to `false`.
    * `:class` (`:a`, `:b`, `:c`, or `nil`) - the private range. Requires `private: true`.
      Defaults to `nil`, which picks one at random.
      * `:a` - `10.0.0.0/8`.
      * `:b` - `172.16.0.0/12`.
      * `:c` - `192.168.0.0/16`.

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
    opts =
      opts
      |> NimbleOptions.validate!(@ipv4_schema)
      |> InternetValidator.validate_requires!(opts, :class, :private)

    if Keyword.fetch!(opts, :private) do
      class = Keyword.fetch!(opts, :class) || Enum.random([:a, :b, :c])
      Generator.private_ipv4(class)
    else
      Generator.public_ipv4()
    end
  end

  @doc """
  Generates a random IPv6 address.

  By default the address is written in full: eight groups of four hex digits.

  ## Options

    * `:uppercase` (boolean) - whether hex digits are uppercase. Defaults to `true`.
    * `:compressed` (boolean) - when `true`, uses the compressed form from RFC 5952:
      leading zeros are dropped and the longest run of zero groups becomes `"::"`.
      Defaults to `false`.

  ## Examples

      iex> NeoFaker.Internet.ipv6()
      "E0E6:7E24:EC6E:E44C:FC69:9C25:CD85:CE08"

      iex> NeoFaker.Internet.ipv6(uppercase: false)
      "e0e6:7e24:ec6e:e44c:fc69:9c25:cd85:ce08"

      iex> NeoFaker.Internet.ipv6(compressed: true, uppercase: false)
      "2001:db8::8a2e:370:7334"

  """
  @spec ipv6(keyword()) :: String.t()
  def ipv6(opts \\ []) do
    opts = NimbleOptions.validate!(opts, @ipv6_schema)

    address =
      if Keyword.fetch!(opts, :compressed),
        do: Generator.compressed_ipv6(),
        else: Generator.ipv6()

    Formatter.apply_case(address, letter_case(opts))
  end

  @doc """
  Generates a random MAC address.

  ## Options

    * `:uppercase` (boolean) - whether hex digits are uppercase. Defaults to `true`.
    * `:separator` (`":"`, `"-"`, or `""`) - the separator between octets. Defaults to
      `":"`.

  ## Examples

      iex> NeoFaker.Internet.mac_address()
      "74:4E:44:B0:D0:93"

      iex> NeoFaker.Internet.mac_address(separator: "-")
      "74-4E-44-B0-D0-93"

      iex> NeoFaker.Internet.mac_address(separator: "", uppercase: false)
      "744e44b0d093"

  """
  @spec mac_address(keyword()) :: String.t()
  def mac_address(opts \\ []) do
    opts = NimbleOptions.validate!(opts, @mac_address_schema)

    opts
    |> Keyword.fetch!(:separator)
    |> Generator.mac_address()
    |> Formatter.apply_case(letter_case(opts))
  end

  @doc """
  Generates a random URL.

  The URL has a scheme and a host, and optionally a path and a query string. Random
  hosts get a TLD from `tld/1`; popular and custom hosts are used as they are.

  ## Options

    * `:protocol` (`:https` or `:http`) - the URL scheme. Defaults to `:https`.
    * `:domain_type` (`:random`, `:popular`, or `:custom`) - how the host is chosen, as
      the `:type` option of `domain_name/1`. Defaults to `:random`.
    * `:word_count` (positive integer) - the number of words in a random host. Defaults
      to `1`.
    * `:popular_type` (`:all`, `:ecommerce`, `:email`, `:search`, or `:social`) - the
      category of a popular host. Defaults to `:all`.
    * `:domain_name` (non-empty string) - the host for `domain_type: :custom`. Defaults
      to `"example.com"`.
    * `:path` (boolean) - whether to append a path of one to three words. Defaults to
      `false`.
    * `:query` (boolean) - whether to append one to three query parameters. Defaults to
      `false`.

  ## Examples

      iex> NeoFaker.Internet.url()
      "https://kappa.com"

      iex> NeoFaker.Internet.url(protocol: :http, domain_type: :popular)
      "http://github.com"

      iex> NeoFaker.Internet.url(path: true, query: true)
      "https://lambda.org/users/profile?page=12&sort=345"

  """
  @spec url(keyword()) :: String.t()
  def url(opts \\ []) do
    opts = NimbleOptions.validate!(opts, @url_schema)
    domain_type = Keyword.fetch!(opts, :domain_type)

    host =
      opts
      |> Keyword.take([:word_count, :popular_type, :domain_name])
      |> Keyword.put(:type, domain_type)
      |> domain_name()

    host = if domain_type == :random, do: host <> tld(), else: host
    path = if Keyword.fetch!(opts, :path), do: "/" <> Generator.url_path(), else: ""
    query = if Keyword.fetch!(opts, :query), do: "?" <> Generator.query_string(), else: ""

    "#{Keyword.fetch!(opts, :protocol)}://#{host}#{path}#{query}"
  end

  @doc """
  Generates a random URL slug of `word_count` lowercase words.

  `word_count` defaults to `3`. Raises `ArgumentError` if it is not a positive integer.

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
  def slug(word_count \\ 3, opts \\ []) do
    word_count = InternetValidator.validate_word_count!(word_count)
    separator = opts |> NimbleOptions.validate!(@slug_schema) |> Keyword.fetch!(:separator)

    random_words(word_count, separator)
  end

  defp random_words(count, separator) do
    Enum.map_join(1..count, separator, fn _ -> Formatter.slugify(Text.word()) end)
  end

  defp letter_case(opts), do: if(Keyword.fetch!(opts, :uppercase), do: :upper, else: :lower)
end
