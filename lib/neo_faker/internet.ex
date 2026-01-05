defmodule NeoFaker.Internet do
  @moduledoc """
  Functions for generating internet-related data.

  This module provides utilities to generate random internet-related information, such as email
  addresses, domain names, URLs, IP addresses, and MAC addresses with comprehensive validation
  and formatting options.
  """
  @moduledoc since: "0.13.0"

  alias NeoFaker.Helpers.Constants
  alias NeoFaker.Helpers.Formatter
  alias NeoFaker.Helpers.Options
  alias NeoFaker.Internet.Domain
  alias NeoFaker.Internet.Email
  alias NeoFaker.Internet.TLD
  alias NeoFaker.Internet.Username

  @valid_username_joiners [:all, :dot, :underscore, :dash]
  @valid_username_types [:person, :word]
  @valid_domain_types [:random, :popular, :custom]
  @valid_popular_domain_types [:all, :ecommerce, :email, :search, :social]
  @valid_tld_types [:all_except_safe, :all, :safe, :generic, :sponsored, :country_code]

  @doc """
  Generates a random username.

  Returns a random username string composed of words joined by specified separators,
  with optional numeric suffix.

  ## Parameters

  - `opts` - Keyword list of options:
    - `:word_count` - Specifies the number of words to include in the username. Defaults to `2`.
    - `:joiner` - Defines the joiner to use between words in the username. Defaults to `:all`.
    - `:username_type` - Specifies the type of words to use in the username. Defaults to `:person`.
    - `:number` - A boolean indicating whether to append a random number to the username. Defaults to `false`.
    - `:number_range` - Defines the range of numbers to choose from when appending a number. Defaults to `1..1000`.

  ## Options

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

      iex> NeoFaker.Internet.username(word_count: 1, joiner: :dash)
      "john-doe"

      iex> NeoFaker.Internet.username(number: true)
      "jane_smith_42"

  """
  @spec username(Keyword.t()) :: String.t()
  def username(opts \\ []) do
    word_count = Options.get(opts, :word_count, Constants.default_username_word_count())
    joiner_type = Options.get(opts, :joiner, :all)
    username_type = Options.get(opts, :username_type, :person)
    include_number = Options.get(opts, :number, false)
    number_range = Options.get(opts, :number_range, Constants.default_number_range())

    validate_username_joiner!(joiner_type)
    validate_username_type!(username_type)
    validate_word_count!(word_count)

    joiner = Username.joiner(joiner_type)

    base =
      Enum.map_join(1..word_count, joiner, fn _ ->
        Username.word(username_type)
      end)

    if include_number do
      base <> joiner <> "#{Enum.random(number_range)}"
    else
      base
    end
  end

  @doc """
  Generates a random domain name.

  Returns a random domain name string based on the specified options. Can generate
  random words, popular domains, or custom domains.

  ## Parameters

  - `opts` - Keyword list of options:
    - `:word_count` - Specifies the number of words to include in the domain name. Defaults to `1`.
    - `:type` - Specifies the type of domain name to generate. Defaults to `:random`.
    - `:popular_type` - When `:type` is `:popular`, defines the category. Defaults to `:all`.
    - `:domain_name` - When `:type` is `:custom`, provides the custom domain. Defaults to `"example.com"`.

  ## Options

  The values for `:type` can be:

  - `:random` - Generates a random domain name using a random word (default).
  - `:popular` - Selects a domain name from a list of popular domains.
  - `:custom` - Uses a custom domain name provided by the user.

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

      iex> NeoFaker.Internet.domain_name(word_count: 2)
      "neo-faker"

  """
  @spec domain_name(keyword()) :: String.t()
  def domain_name(opts \\ []) do
    word_count = Options.get(opts, :word_count, Constants.default_domain_word_count())
    domain_type = Options.get(opts, :type, :random)
    popular_type = Options.get(opts, :popular_type, :all)

    validate_domain_type!(domain_type)

    case domain_type do
      :random ->
        validate_word_count!(word_count)
        Enum.map_join(1..word_count, "-", fn _ -> String.downcase(NeoFaker.Text.word()) end)

      :popular ->
        validate_popular_domain_type!(popular_type)
        Domain.generate_popular_domain_name(popular_type)

      :custom ->
        Options.get(opts, :domain_name, "example.com")
    end
  end

  @doc """
  Generates a random top-level domain (TLD).

  Returns a random TLD string with optional leading dot.

  ## Parameters

  - `opts` - Keyword list of options:
    - `:dot` - A boolean indicating whether to include a leading dot in the TLD. Defaults to `true`.
    - `:type` - Specifies the type of TLD to generate. Defaults to `:all_except_safe`.

  ## Options

  The values for `:type` can be:

  - `:all_except_safe` - Returns a TLD from all types except safe TLDs (default).
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

      iex> NeoFaker.Internet.tld(type: :generic, dot: false)
      "net"

  """
  @spec tld(Keyword.t()) :: String.t()
  def tld(opts \\ []) do
    tld_type = Options.get(opts, :type, :all_except_safe)
    include_dot = Options.get(opts, :dot, true)

    validate_tld_type!(tld_type)

    tld_name = TLD.generate_name(tld_type)

    if include_dot do
      "." <> tld_name
    else
      tld_name
    end
  end

  @doc """
  Generates a random email address.

  Returns a random email address string based on the specified options, combining
  username, domain, and TLD generation with flexible customization.

  ## Parameters

  - `opts` - Keyword list of options supporting username, domain, and TLD customization.

  ## Username Options

  - `:username_word_count` - Specifies the number of words to include in the username. Defaults to `2`.
  - `:joiner` - Defines the joiner to use between words in the username. Defaults to `:all`.
  - `:username_type` - Specifies the type of words to use in the username. Defaults to `:person`.
  - `:number` - A boolean indicating whether to append a random number to the username. Defaults to `false`.
  - `:number_range` - Defines the range of numbers to choose from when appending a number. Defaults to `1..1000`.

  ## Domain Name Options

  - `:domain_name_word_count` - Specifies the number of words to include in the domain name. Defaults to `1`.
  - `:domain_type` - Specifies the type of domain name to generate. Defaults to `:random`.
  - `:popular_type` - When `:domain_type` is set to `:popular`, defines the category. Defaults to `:all`.
  - `:domain_name` - When `:domain_type` is set to `:custom`, provides the custom domain. Defaults to `"example.com"`.

  ## TLD Options

  - `:tld_type` - Specifies the type of TLD to generate. Defaults to `:all_except_safe`.

  ## Examples

      iex> NeoFaker.Internet.email()
      "josé@example.com"

      iex> NeoFaker.Internet.email(username_word_count: 3, joiner: :dot, number: true)
      "abigail.bethany.crawford_202@example.com"

      iex> NeoFaker.Internet.email(domain_type: :popular, popular_type: :email)
      "jane.doe@gmail.com"

      iex> NeoFaker.Internet.email(domain_type: :custom, domain_name: "elixir-lang.org")
      "josé@elixir-lang.org"

      iex> NeoFaker.Internet.email(tld_type: :country_code)
      "user@example.id"

  """
  @spec email(Keyword.t()) :: String.t()
  def email(opts \\ []) do
    username = Email.generate_username(opts)
    domain_name = Email.generate_domain_name(opts)
    tld = Email.generate_tld(opts)

    domain_type = Options.get(opts, :domain_type, :random)

    if domain_type in [:popular, :custom] do
      "#{username}@#{domain_name}"
    else
      "#{username}@#{domain_name}#{tld}"
    end
  end

  @doc """
  Generates a random IPv4 address.

  Returns a random IPv4 address string in dotted-decimal notation.

  ## Parameters

  - `opts` - Keyword list of options:
    - `:private` - When `true`, generates a private IP address. Defaults to `false`.
    - `:class` - Specifies the private IP class when `:private` is `true`.

  ## Options

  The values for `:class` can be:

  - `:a` - Class A private range (10.0.0.0/8).
  - `:b` - Class B private range (172.16.0.0/12).
  - `:c` - Class C private range (192.168.0.0/16).

  ## Examples

      iex> NeoFaker.Internet.ipv4()
      "183.235.34.108"

      iex> NeoFaker.Internet.ipv4()
      "192.0.2.146"

      iex> NeoFaker.Internet.ipv4(private: true)
      "192.168.1.42"

      iex> NeoFaker.Internet.ipv4(private: true, class: :a)
      "10.25.30.100"

  """
  @spec ipv4(Keyword.t()) :: String.t()
  def ipv4(opts \\ []) do
    private = Options.get(opts, :private, false)

    if private do
      class = Options.get(opts, :class, Enum.random([:a, :b, :c]))
      generate_private_ipv4(class)
    else
      generate_public_ipv4()
    end
  end

  @doc """
  Generates a random IPv6 address.

  Returns a random IPv6 address string in hexadecimal notation.

  ## Parameters

  - `opts` - Keyword list of options:
    - `:uppercase` - A boolean indicating whether to return the address in uppercase. Defaults to `true`.
    - `:compressed` - When `true`, uses compressed notation (::). Defaults to `false`.

  ## Examples

      iex> NeoFaker.Internet.ipv6()
      "E0E6:7E24:EC6E:E44C:FC69:9C25:CD85:CE08"

      iex> NeoFaker.Internet.ipv6(uppercase: false)
      "e0e6:7e24:ec6e:e44c:fc69:9c25:cd85:ce08"

      iex> NeoFaker.Internet.ipv6(compressed: true)
      "2001:db8::8a2e:370:7334"

  """
  @spec ipv6(Keyword.t()) :: String.t()
  def ipv6(opts \\ []) do
    uppercase = Options.get(opts, :uppercase, true)

    ip_address =
      if Options.get(opts, :compressed, false) do
        generate_compressed_ipv6()
      else
        Enum.map_join(1..8, ":", fn _ ->
          (:rand.uniform(0x10_000) - 1)
          |> Integer.to_string(16)
          |> String.pad_leading(4, "0")
        end)
      end

    Formatter.apply_case(ip_address, if(uppercase, do: :upper, else: :lower))
  end

  @doc """
  Generates a random MAC address.

  Returns a random MAC address string in colon-separated hexadecimal notation.

  ## Parameters

  - `opts` - Keyword list of options:
    - `:uppercase` - A boolean indicating whether to return the MAC address in uppercase. Defaults to `true`.
    - `:separator` - The separator to use between octets. Defaults to `":"`.

  ## Options

  The values for `:separator` can be:

  - `":"` - Colon separator (default).
  - `"-"` - Dash separator.
  - `""` - No separator.

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
  @spec mac_address(Keyword.t()) :: String.t()
  def mac_address(opts \\ []) do
    uppercase = Options.get(opts, :uppercase, true)
    separator = Options.get(opts, :separator, ":")

    validate_mac_separator!(separator)

    mac_address =
      Enum.map_join(1..6, separator, fn _ ->
        (:rand.uniform(0x100) - 1)
        |> Integer.to_string(16)
        |> String.pad_leading(2, "0")
      end)

    Formatter.apply_case(mac_address, if(uppercase, do: :upper, else: :lower))
  end

  @doc """
  Generates a random URL.

  Returns a random URL string with specified protocol, domain, and path options.

  ## Parameters

  - `opts` - Keyword list of options:
    - `:protocol` - The URL protocol. Defaults to `:https`.
    - `:domain_type` - The type of domain to use. Defaults to `:random`.
    - `:path` - When `true`, includes a random path. Defaults to `false`.
    - `:query` - When `true`, includes query parameters. Defaults to `false`.

  ## Options

  The values for `:protocol` can be:

  - `:https` - HTTPS protocol (default).
  - `:http` - HTTP protocol.

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
  @spec url(Keyword.t()) :: String.t()
  def url(opts \\ []) do
    protocol = Options.get(opts, :protocol, :https)
    include_path = Options.get(opts, :path, false)
    include_query = Options.get(opts, :query, false)

    validate_protocol!(protocol)

    domain = domain_name(opts)
    tld_name = tld(opts)

    base_url = "#{protocol}://#{domain}#{tld_name}"

    url_with_path =
      if include_path do
        path = generate_url_path()
        "#{base_url}/#{path}"
      else
        base_url
      end

    if include_query do
      query = generate_query_string()
      "#{url_with_path}?#{query}"
    else
      url_with_path
    end
  end

  @doc """
  Generates a random slug.

  Returns a URL-friendly slug string.

  ## Parameters

  - `word_count` - The number of words in the slug. Defaults to `3`.
  - `opts` - Keyword list of options:
    - `:separator` - The separator between words. Defaults to `"-"`.

  ## Examples

      iex> NeoFaker.Internet.slug()
      "neo-faker-elixir"

      iex> NeoFaker.Internet.slug(5)
      "the-quick-brown-fox-jumps"

      iex> NeoFaker.Internet.slug(2, separator: "_")
      "hello_world"

  """
  @spec slug(pos_integer(), Keyword.t()) :: String.t()
  def slug(word_count \\ 3, opts \\ []) when is_integer(word_count) and word_count > 0 do
    separator = Options.get(opts, :separator, "-")

    Enum.map_join(1..word_count, separator, fn _ ->
      String.downcase(NeoFaker.Text.word())
    end)
  end

  # Private functions

  @spec generate_public_ipv4() :: String.t()
  defp generate_public_ipv4 do
    Enum.map_join(1..4, ".", fn _ -> :rand.uniform(256) - 1 end)
  end

  @spec generate_private_ipv4(atom()) :: String.t()
  defp generate_private_ipv4(:a) do
    "10.#{:rand.uniform(256) - 1}.#{:rand.uniform(256) - 1}.#{:rand.uniform(256) - 1}"
  end

  defp generate_private_ipv4(:b) do
    "172.#{:rand.uniform(16) + 15}.#{:rand.uniform(256) - 1}.#{:rand.uniform(256) - 1}"
  end

  defp generate_private_ipv4(:c) do
    "192.168.#{:rand.uniform(256) - 1}.#{:rand.uniform(256) - 1}"
  end

  @spec generate_compressed_ipv6() :: String.t()
  defp generate_compressed_ipv6 do
    # Generate 8 groups but compress some zeros
    groups =
      Enum.map(1..8, fn _ ->
        :rand.uniform(0x10_000) - 1
      end)

    # Find longest sequence of zeros
    {start_idx, length} = find_longest_zero_sequence(groups)

    if length > 1 do
      # Create compressed notation
      before = Enum.take(groups, start_idx)
      after_groups = Enum.drop(groups, start_idx + length)

      before_str = format_ipv6_groups(before)
      after_str = format_ipv6_groups(after_groups)

      case {before_str, after_str} do
        {"", ""} -> "::"
        {"", _} -> "::#{after_str}"
        {_, ""} -> "#{before_str}::"
        _ -> "#{before_str}::#{after_str}"
      end
    else
      # No compression
      format_ipv6_groups(groups)
    end
  end

  @spec find_longest_zero_sequence(list(integer())) :: {integer(), integer()}
  defp find_longest_zero_sequence(groups) do
    groups
    |> Enum.with_index()
    |> Enum.chunk_by(fn {val, _} -> val == 0 end)
    |> Enum.filter(fn chunk ->
      case chunk do
        [{0, _} | _] -> true
        _ -> false
      end
    end)
    |> Enum.max_by(fn chunk -> length(chunk) end, fn -> [] end)
    |> case do
      [] -> {0, 0}
      chunk -> {elem(hd(chunk), 1), length(chunk)}
    end
  end

  @spec format_ipv6_groups(list(integer())) :: String.t()
  defp format_ipv6_groups([]), do: ""

  defp format_ipv6_groups(groups) do
    Enum.map_join(groups, ":", &Integer.to_string(&1, 16))
  end

  @spec generate_url_path() :: String.t()
  defp generate_url_path do
    path_depth = :rand.uniform(3)

    Enum.map_join(1..path_depth, "/", fn _ ->
      String.downcase(NeoFaker.Text.word())
    end)
  end

  @spec generate_query_string() :: String.t()
  defp generate_query_string do
    param_count = :rand.uniform(3)

    Enum.map_join(1..param_count, "&", fn _ ->
      key = String.downcase(NeoFaker.Text.word())
      value = :rand.uniform(1000)
      "#{key}=#{value}"
    end)
  end

  # Validation functions

  @spec validate_username_joiner!(atom()) :: :ok
  defp validate_username_joiner!(joiner) do
    case Options.validate_enum(:joiner, joiner, @valid_username_joiners) do
      :ok ->
        :ok

      {:error, reason} ->
        raise ArgumentError, reason
    end
  end

  @spec validate_username_type!(atom()) :: :ok
  defp validate_username_type!(type) do
    case Options.validate_enum(:username_type, type, @valid_username_types) do
      :ok ->
        :ok

      {:error, reason} ->
        raise ArgumentError, reason
    end
  end

  @spec validate_domain_type!(atom()) :: :ok
  defp validate_domain_type!(type) do
    case Options.validate_enum(:type, type, @valid_domain_types) do
      :ok ->
        :ok

      {:error, reason} ->
        raise ArgumentError, reason
    end
  end

  @spec validate_popular_domain_type!(atom()) :: :ok
  defp validate_popular_domain_type!(type) do
    case Options.validate_enum(:popular_type, type, @valid_popular_domain_types) do
      :ok ->
        :ok

      {:error, reason} ->
        raise ArgumentError, reason
    end
  end

  @spec validate_tld_type!(atom()) :: :ok
  defp validate_tld_type!(type) do
    case Options.validate_enum(:type, type, @valid_tld_types) do
      :ok ->
        :ok

      {:error, reason} ->
        raise ArgumentError, reason
    end
  end

  @spec validate_word_count!(pos_integer()) :: :ok
  defp validate_word_count!(count) when is_integer(count) and count > 0, do: :ok

  defp validate_word_count!(count) when is_integer(count) do
    raise ArgumentError, "word_count must be a positive integer, got: #{count}"
  end

  defp validate_word_count!(count) do
    raise ArgumentError, "word_count must be a positive integer, got: #{inspect(count)}"
  end

  @spec validate_mac_separator!(String.t()) :: :ok
  defp validate_mac_separator!(sep) when sep in [":", "-", ""], do: :ok

  defp validate_mac_separator!(sep) do
    raise ArgumentError,
          "Invalid MAC separator. Expected one of [\":\", \"-\", \"\"], got: #{inspect(sep)}"
  end

  @spec validate_protocol!(atom()) :: :ok
  defp validate_protocol!(protocol) when protocol in [:http, :https], do: :ok

  defp validate_protocol!(protocol) do
    raise ArgumentError,
          "Invalid protocol. Expected one of [:http, :https], got: #{inspect(protocol)}"
  end
end
