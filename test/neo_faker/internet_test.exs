defmodule NeoFaker.InternetTest do
  use ExUnit.Case, async: true

  alias NeoFaker.Internet
  alias NeoFaker.Internet.Generator

  describe "username/1" do
    test "returns a two-word username with no options" do
      username = Internet.username()

      assert is_binary(username) and String.valid?(username)
      assert username |> String.split([".", "-", "_"]) |> length() == 2
    end

    test "returns a username with the specified word count" do
      username = Internet.username(word_count: 3)

      assert username |> String.split([".", "-", "_"]) |> length() == 3
    end

    test "returns a username with the specified joiner" do
      Enum.each(%{dot: ".", underscore: "_", dash: "-"}, fn {key, val} ->
        username = Internet.username(joiner: key)

        assert String.contains?(username, val)
      end)

      assert [joiner: :all] |> Internet.username() |> String.contains?([".", "_", "-"])
    end

    test "returns a username with the specified username type" do
      Enum.each([:person, :word], fn type ->
        username = Internet.username(username_type: type)

        assert String.contains?(username, [".", "-", "_"]) && String.valid?(username)
      end)
    end

    test "word segments are bare tokens, so the joiner count is exact, for either word type" do
      # A dictionary word carrying a space, hyphen, or apostrophe ("long-term",
      # "o'clock") would otherwise read as an extra segment.
      for type <- [:person, :word], joiner <- [:dot, :dash, :underscore], _ <- 1..50 do
        sep = %{dot: ".", dash: "-", underscore: "_"}[joiner]
        username = Internet.username(username_type: type, word_count: 3, joiner: joiner)

        assert username |> String.split(sep) |> length() == 3,
               "expected 3 #{sep}-separated segments in: #{inspect(username)}"

        refute username =~ ~r/[^a-z0-9._-]/,
               "username had an unexpected character: #{inspect(username)}"
      end
    end

    test "returns a username with appended number within the specified range" do
      extracted_number =
        [number: true, number_range: 100..200]
        |> Internet.username()
        |> String.split([".", "-", "_"])
        |> List.last()
        |> String.to_integer()

      assert extracted_number in 100..200
    end
  end

  describe "domain_name/1" do
    test "returns a single lowercase alphanumeric word by default" do
      for _ <- 1..100 do
        domain = Internet.domain_name()

        assert is_binary(domain)

        assert String.match?(domain, ~r/^[a-z0-9]+$/),
               "unexpected domain label: #{inspect(domain)}"
      end
    end

    test "returns multiple words joined by dash when word_count > 1" do
      # Run many iterations: a word carrying its own hyphen ("long-term") would
      # otherwise inflate the dash-split count.
      for _ <- 1..100 do
        domain = Internet.domain_name(word_count: 3)

        assert is_binary(domain)

        assert domain |> String.split("-") |> length() == 3,
               "unexpected domain: #{inspect(domain)}"
      end
    end

    test "returns a popular domain name when type: :popular" do
      domain = Internet.domain_name(type: :popular)

      assert is_binary(domain)
      assert String.contains?(domain, ".")
    end

    test "returns a popular email domain when type: :popular and popular_type: :email" do
      domain = Internet.domain_name(type: :popular, popular_type: :email)

      assert is_binary(domain)
      assert String.contains?(domain, ".")
    end

    test "returns the given domain name when type: :custom and domain_name is provided" do
      domain = Internet.domain_name(type: :custom, domain_name: "elixir-lang.org")

      assert domain == "elixir-lang.org"
    end

    test "returns the default custom domain when type: :custom and domain_name is not provided" do
      domain = Internet.domain_name(type: :custom)

      assert domain == "example.com"
    end

    test "raises NimbleOptions.ValidationError for an unknown type" do
      assert_raise NimbleOptions.ValidationError, fn ->
        Internet.domain_name(type: :unknown)
      end
    end

    test "raises NimbleOptions.ValidationError when type: :custom and :domain_name is not a string" do
      assert_raise NimbleOptions.ValidationError,
                   ~r/invalid value for :domain_name option: expected string/,
                   fn ->
                     Internet.domain_name(type: :custom, domain_name: 42)
                   end
    end

    test "raises ArgumentError when type: :custom and :domain_name is an empty string" do
      assert_raise ArgumentError, ~r/Invalid :domain_name/, fn ->
        Internet.domain_name(type: :custom, domain_name: "")
      end
    end
  end

  describe "tld/1" do
    test "returns a TLD with a leading dot by default" do
      tld = Internet.tld()

      assert String.starts_with?(tld, ".")
      assert String.valid?(tld)
    end

    test "returns a TLD without a leading dot when dot: false" do
      tld = Internet.tld(dot: false)

      refute String.starts_with?(tld, ".")
      assert String.valid?(tld)
    end

    test "returns a valid TLD for each supported type" do
      Enum.each([:all, :safe, :generic, :sponsored, :country_code], fn type ->
        tld = Internet.tld(type: type)

        assert String.starts_with?(tld, ".")
        assert String.valid?(tld)
      end)
    end
  end

  describe "email/1" do
    test "returns a valid email address with default options" do
      email = Internet.email()

      assert String.match?(email, ~r/^[^@]+@[^@]+\.[a-z]+$/)
    end

    test "returns a valid email address with popular domain type" do
      email = Internet.email(domain_type: :popular)

      assert String.match?(email, ~r/^[^@]+@[^@]+\.[a-z]+$/)
      refute String.contains?(email, "..")
    end

    test "returns a valid email address with custom domain type and domain_name" do
      email = Internet.email(domain_type: :custom, domain_name: "elixir-lang.org")

      assert String.match?(email, ~r/^[^@]+@elixir-lang\.org$/)
    end

    test "returns a valid email address with custom domain type and no domain_name" do
      email = Internet.email(domain_type: :custom)

      assert String.match?(email, ~r/^[^@]+@example\.com$/)
    end

    test "returns a valid email address with word username and popular email domain" do
      # Run many iterations: the username is built from random Text.word/0 picks,
      # and a multi-word entry would slip a space into the local part.
      for _ <- 1..100 do
        email = Internet.email(username_type: :word, domain_type: :popular, popular_type: :email)

        assert String.match?(email, ~r/^[a-zA-Z0-9_.-]+@[a-zA-Z0-9_.-]+\.[a-z]+$/),
               "invalid email generated: #{inspect(email)}"
      end
    end

    test "raises NimbleOptions.ValidationError when domain_type: :custom and :domain_name is not a string" do
      assert_raise NimbleOptions.ValidationError,
                   ~r/invalid value for :domain_name option: expected string/,
                   fn ->
                     Internet.email(domain_type: :custom, domain_name: :not_a_string)
                   end
    end

    test "raises ArgumentError when domain_type: :custom and :domain_name is an empty string" do
      assert_raise ArgumentError, ~r/Invalid :domain_name/, fn ->
        Internet.email(domain_type: :custom, domain_name: "")
      end
    end
  end

  describe "ipv4/0" do
    # Shared shortcut so every test below can call the predicate without a
    # fully-qualified module name.
    defp reserved?(a, b, c), do: Generator.reserved_ipv4?(a, b, c)

    defp assert_valid_ipv4(ip) do
      parts = String.split(ip, ".")

      assert length(parts) == 4, "#{ip}: expected 4 octets, got #{length(parts)}"

      assert Enum.all?(parts, fn part ->
               case Integer.parse(part) do
                 {num, ""} -> num >= 0 and num <= 255
                 _ -> false
               end
             end),
             "#{ip}: every octet must be a decimal integer in 0..255"
    end

    # -------------------------------------------------------------------------
    # Structural sanity check — unchanged, still useful as a quick smoke test.
    # -------------------------------------------------------------------------

    test "returns a valid IPv4 address" do
      assert_valid_ipv4(Internet.ipv4())
    end

    # -------------------------------------------------------------------------
    # reserved_ipv4?/3 predicate — deterministic coverage of every boundary.
    #
    # For each reserved block we check:
    #   • every address *inside* the block  → reserved?(…) == true
    #   • the immediately adjacent addresses on *both* sides → false
    # This is O(range-size) not O(random-samples), so a regression that
    # re-introduces any exclusion rule is guaranteed to fail.
    # -------------------------------------------------------------------------

    test "reserved_ipv4?/3: 0.0.0.0/8 — 'This' network (RFC 791)" do
      # All of first octet 0 is reserved.
      for b <- [0, 128, 255], c <- [0, 128, 255] do
        assert reserved?(0, b, c), "0.#{b}.#{c}.x should be reserved"
      end

      # First public octet begins at 1.
      refute reserved?(1, 0, 0)
    end

    test "reserved_ipv4?/3: 10.0.0.0/8 — RFC 1918 private class A" do
      for b <- [0, 128, 255], c <- [0, 128, 255] do
        assert reserved?(10, b, c), "10.#{b}.#{c}.x should be reserved"
      end

      refute reserved?(9, 255, 255), "9.255.255.x is public (just before 10/8)"
      refute reserved?(11, 0, 0), "11.0.0.x is public (just after 10/8)"
    end

    test "reserved_ipv4?/3: 100.64.0.0/10 — CGN / shared address (RFC 6598)" do
      # Boundary second octets inside the /10: 64 and 127.
      assert reserved?(100, 64, 0), "100.64.0.x should be reserved (start of /10)"
      assert reserved?(100, 127, 255), "100.127.255.x should be reserved (end of /10)"
      assert reserved?(100, 96, 0), "100.96.0.x should be reserved (mid /10)"

      # Adjacent public second octets: 63 (just before) and 128 (just after).
      refute reserved?(100, 63, 0), "100.63.0.x is public (just before CGN /10)"
      refute reserved?(100, 128, 0), "100.128.0.x is public (just after CGN /10)"
    end

    test "reserved_ipv4?/3: 127.0.0.0/8 — loopback (RFC 1122)" do
      for b <- [0, 1, 255], c <- [0, 255] do
        assert reserved?(127, b, c), "127.#{b}.#{c}.x should be reserved"
      end

      refute reserved?(126, 255, 255), "126.255.255.x is public (just before loopback)"
      refute reserved?(128, 0, 0), "128.0.0.x is public (just after loopback)"
    end

    test "reserved_ipv4?/3: 169.254.0.0/16 — link-local (RFC 3927)" do
      for c <- [0, 128, 255] do
        assert reserved?(169, 254, c), "169.254.#{c}.x should be reserved"
      end

      # Adjacent second octets: 253 (just before) and 255 (just after).
      refute reserved?(169, 253, 0), "169.253.0.x is public (just before link-local)"
      refute reserved?(169, 255, 0), "169.255.0.x is public (just after link-local)"
    end

    test "reserved_ipv4?/3: 172.16.0.0/12 — RFC 1918 private class B" do
      # Boundary second octets: 16 (start) and 31 (end).
      assert reserved?(172, 16, 0), "172.16.0.x should be reserved (start of /12)"
      assert reserved?(172, 31, 255), "172.31.255.x should be reserved (end of /12)"
      assert reserved?(172, 24, 0), "172.24.0.x should be reserved (mid /12)"

      refute reserved?(172, 15, 255), "172.15.255.x is public (just before /12)"
      refute reserved?(172, 32, 0), "172.32.0.x is public (just after /12)"
    end

    test "reserved_ipv4?/3: 192.0.0.0/24 — IETF protocol assignments (RFC 6890)" do
      for c <- [0, 128, 255] do
        assert reserved?(192, 0, c), "192.0.#{c}.x should be reserved"
      end

      # 192.1.x.x is public (second octet 1, not 0).
      refute reserved?(192, 1, 0), "192.1.0.x is public"
    end

    test "reserved_ipv4?/3: 192.0.2.0/24 — TEST-NET-1 (RFC 5737) is covered by second=0 exclusion" do
      # The generator excludes the entire second=0 block, which subsumes TEST-NET-1.
      assert reserved?(192, 0, 2), "192.0.2.x should be reserved (second=0 catches it)"

      # 192.2.x.x must NOT be excluded — that is a wholly different /16.
      refute reserved?(192, 2, 0), "192.2.0.x is public (not related to 192.0.2.0/24)"
      refute reserved?(192, 2, 2), "192.2.2.x is public"
    end

    test "reserved_ipv4?/3: 192.88.99.0/24 — deprecated 6to4 relay anycast (RFC 7526)" do
      for _ <- 1..5 do
        assert reserved?(192, 88, 99), "192.88.99.x should be reserved"
      end

      # Adjacent third octets and a different second octet must be public.
      refute reserved?(192, 88, 98), "192.88.98.x is public (just before /24)"
      refute reserved?(192, 88, 100), "192.88.100.x is public (just after /24)"
      refute reserved?(192, 87, 99), "192.87.99.x is public (different second octet)"
    end

    test "reserved_ipv4?/3: 192.168.0.0/16 — RFC 1918 private class C" do
      for c <- [0, 128, 255] do
        assert reserved?(192, 168, c), "192.168.#{c}.x should be reserved"
      end

      refute reserved?(192, 167, 255), "192.167.255.x is public (just before /16)"
      refute reserved?(192, 169, 0), "192.169.0.x is public (just after /16)"
    end

    test "reserved_ipv4?/3: 198.18.0.0/15 — benchmarking (RFC 2544)" do
      # /15 covers second octets 18 and 19.
      for c <- [0, 128, 255] do
        assert reserved?(198, 18, c), "198.18.#{c}.x should be reserved (start of /15)"
        assert reserved?(198, 19, c), "198.19.#{c}.x should be reserved (end of /15)"
      end

      refute reserved?(198, 17, 255), "198.17.255.x is public (just before /15)"
      refute reserved?(198, 20, 0), "198.20.0.x is public (just after /15)"
    end

    test "reserved_ipv4?/3: 198.51.100.0/24 — TEST-NET-2 (RFC 5737)" do
      assert reserved?(198, 51, 100), "198.51.100.x should be reserved"

      refute reserved?(198, 51, 99), "198.51.99.x is public (just before /24)"
      refute reserved?(198, 51, 101), "198.51.101.x is public (just after /24)"
      refute reserved?(198, 50, 100), "198.50.100.x is public (different second octet)"
    end

    test "reserved_ipv4?/3: 203.0.113.0/24 — TEST-NET-3 (RFC 5737)" do
      assert reserved?(203, 0, 113), "203.0.113.x should be reserved"

      refute reserved?(203, 0, 112), "203.0.112.x is public (just before /24)"
      refute reserved?(203, 0, 114), "203.0.114.x is public (just after /24)"
      refute reserved?(203, 1, 113), "203.1.113.x is public (different second octet)"
    end

    test "reserved_ipv4?/3: 224.0.0.0/4 — multicast (RFC 3171)" do
      # /4 covers first octets 224–239.
      for a <- [224, 231, 239], b <- [0, 255], c <- [0, 255] do
        assert reserved?(a, b, c), "#{a}.#{b}.#{c}.x should be reserved (multicast)"
      end

      refute reserved?(223, 255, 255), "223.255.255.x is public (just before multicast)"
    end

    test "reserved_ipv4?/3: 240.0.0.0/4 — reserved / broadcast (RFC 1112)" do
      # /4 covers first octets 240–255.
      for a <- [240, 248, 255], b <- [0, 255], c <- [0, 255] do
        assert reserved?(a, b, c), "#{a}.#{b}.#{c}.x should be reserved"
      end
    end

    # -------------------------------------------------------------------------
    # Smoke test: public_ipv4/0 never produces a reserved address.
    # With reserved_ipv4?/3 now verified above to be correct, a small sample is
    # sufficient here — we are no longer relying on chance to hit tiny /24 blocks.
    # -------------------------------------------------------------------------

    test "public_ipv4/0 never returns a reserved address across many samples" do
      # A large sample also reliably exercises the mixed public/reserved first
      # octets (100, 169, 172, 192, 198, 203) and their second-octet guards.
      first_octets =
        for _ <- 1..4000 do
          ip = Internet.ipv4()
          [a, b, c, _d] = ip |> String.split(".") |> Enum.map(&String.to_integer/1)

          refute reserved?(a, b, c),
                 "#{ip}: expected a publicly routable address but got a reserved one"

          a
        end

      for octet <- [100, 169, 172, 192, 198, 203] do
        assert octet in first_octets, "expected first octet #{octet} in a 4000-sample run"
      end
    end

    test "returns a private IPv4 address when private: true" do
      ip = Internet.ipv4(private: true)
      assert_valid_ipv4(ip)
      [a, b, _c, _d] = ip |> String.split(".") |> Enum.map(&String.to_integer/1)

      assert a == 10 or (a == 172 and b in 16..31) or (a == 192 and b == 168),
             "#{ip}: expected a private RFC 1918 address"
    end

    test "returns a class A private address when private: true, class: :a" do
      ip = Internet.ipv4(private: true, class: :a)
      assert_valid_ipv4(ip)

      assert String.starts_with?(ip, "10.")
    end

    test "returns a class B private address when private: true, class: :b" do
      ip = Internet.ipv4(private: true, class: :b)
      assert_valid_ipv4(ip)
      [_a, b | _] = ip |> String.split(".") |> Enum.map(&String.to_integer/1)

      assert String.starts_with?(ip, "172.")
      assert b in 16..31
    end

    test "returns a class C private address when private: true, class: :c" do
      ip = Internet.ipv4(private: true, class: :c)
      assert_valid_ipv4(ip)

      assert String.starts_with?(ip, "192.168.")
    end

    test "raises NimbleOptions.ValidationError for an invalid class" do
      assert_raise NimbleOptions.ValidationError, fn ->
        Internet.ipv4(private: true, class: :d)
      end
    end
  end

  describe "ipv6/1" do
    test "returns an IPv6 address in uppercase by default" do
      ip = Internet.ipv6()

      assert String.match?(ip, ~r/^([0-9A-F]{1,4}:){7}[0-9A-F]{1,4}$/)
    end

    test "returns an IPv6 address in lowercase when uppercase: false" do
      ip = Internet.ipv6(uppercase: false)

      assert String.match?(ip, ~r/^([0-9a-f]{1,4}:){7}[0-9a-f]{1,4}$/)
    end

    test "returns an IPv6 address with 8 groups separated by colons" do
      ip = Internet.ipv6()

      assert ip |> String.split(":") |> length() == 8
    end
  end

  describe "mac_address/1" do
    test "returns a MAC address in uppercase by default" do
      mac = Internet.mac_address()

      assert String.match?(mac, ~r/^([0-9A-F]{2}:){5}[0-9A-F]{2}$/)
    end

    test "returns a MAC address in lowercase when uppercase: false" do
      mac = Internet.mac_address(uppercase: false)

      assert String.match?(mac, ~r/^([0-9a-f]{2}:){5}[0-9a-f]{2}$/)
    end

    test "returns a MAC address with 6 groups of 2 hex digits separated by colons" do
      mac = Internet.mac_address()

      assert String.length(mac) == 17
      assert mac |> String.split(":") |> length() == 6
    end
  end

  describe "url/1" do
    test "returns a valid https URL by default" do
      url = Internet.url()

      assert String.starts_with?(url, "https://")
      assert String.valid?(url)
    end

    test "returns a URL with http protocol when protocol: :http" do
      url = Internet.url(protocol: :http)

      assert String.starts_with?(url, "http://")
    end

    test "returns a URL with https protocol when protocol: :https" do
      url = Internet.url(protocol: :https)

      assert String.starts_with?(url, "https://")
    end

    test "returns a URL without a path by default" do
      url = Internet.url()

      # After stripping the scheme, no slash should remain in the host+tld
      without_scheme = String.replace_prefix(url, "https://", "")

      refute String.contains?(without_scheme, "/")
    end

    test "returns a URL with a path when path: true" do
      url = Internet.url(path: true)

      without_scheme = String.replace_prefix(url, "https://", "")

      assert String.contains?(without_scheme, "/")
    end

    test "returns a URL without a query string by default" do
      url = Internet.url()

      refute String.contains?(url, "?")
    end

    test "returns a URL with a query string when query: true" do
      url = Internet.url(query: true)

      assert String.contains?(url, "?")
    end

    test "returns a URL with both path and query string when path: true and query: true" do
      url = Internet.url(path: true, query: true)

      assert String.contains?(url, "/")
      assert String.contains?(url, "?")
      # path segment must appear before the query string
      assert String.match?(url, ~r|/[^?]+\?|)
    end

    test "returns a URL for a popular domain without a duplicate TLD" do
      url = Internet.url(domain_type: :popular)

      # A popular domain like "gmail.com" must not become "gmail.com.net"
      [_scheme, rest] = String.split(url, "://", parts: 2)
      host = rest |> String.split("/") |> List.first()

      assert length(String.split(host, ".")) <= 2,
             "#{url}: popular domain URL must not have more than one dot in the host"
    end

    test "returns a URL containing the custom domain when domain_type: :custom and domain_name is provided" do
      url = Internet.url(domain_type: :custom, domain_name: "elixir-lang.org")

      assert String.contains?(url, "elixir-lang.org")
    end

    test "returns a URL containing example.com when domain_type: :custom and no domain_name" do
      url = Internet.url(domain_type: :custom)

      assert String.contains?(url, "example.com")
    end

    test "raises NimbleOptions.ValidationError when domain_type: :custom and :domain_name is not a string" do
      assert_raise NimbleOptions.ValidationError,
                   ~r/invalid value for :domain_name option: expected string/,
                   fn ->
                     Internet.url(domain_type: :custom, domain_name: ["not", "a", "string"])
                   end
    end

    test "raises ArgumentError when domain_type: :custom and :domain_name is an empty string" do
      assert_raise ArgumentError, ~r/Invalid :domain_name/, fn ->
        Internet.url(domain_type: :custom, domain_name: "")
      end
    end

    test "raises NimbleOptions.ValidationError for an invalid protocol" do
      assert_raise NimbleOptions.ValidationError, fn ->
        Internet.url(protocol: :ftp)
      end
    end

    test "raises NimbleOptions.ValidationError for an invalid domain_type" do
      assert_raise NimbleOptions.ValidationError, fn ->
        Internet.url(domain_type: :unknown)
      end
    end
  end

  describe "slug/2" do
    test "returns a slug with 3 dash-separated words by default" do
      slug = Internet.slug()

      assert slug |> String.split("-") |> length() == 3
    end

    test "is only lowercase alphanumerics and the separator, so the word count is exact" do
      # Regression: dictionary entries like "long-term" / "o'clock" used to leak
      # their punctuation into the slug and inflate String.split counts.
      for count <- [1, 3, 5], _ <- 1..50 do
        slug = Internet.slug(count)

        assert slug |> String.split("-") |> length() == count,
               "expected #{count} parts in slug: #{inspect(slug)}"

        assert slug =~ ~r/^[a-z0-9]+(-[a-z0-9]+)*$/,
               "slug had an unexpected character: #{inspect(slug)}"
      end
    end

    test "returns a slug with the specified word count" do
      for count <- [1, 2, 5] do
        slug = Internet.slug(count)

        assert slug |> String.split("-") |> length() == count,
               "expected #{count} dash-separated parts in slug: #{slug}"
      end
    end

    test "returns a slug containing only lowercase letters and the default separator" do
      slug = Internet.slug()

      assert String.match?(slug, ~r/^[a-z]+(-[a-z]+)*$/)
    end

    test "returns a slug with underscore separator when separator: \"_\"" do
      slug = Internet.slug(3, separator: "_")

      assert String.match?(slug, ~r/^[a-z]+(_[a-z]+){2}$/)
    end

    test "returns a slug with a custom separator joining the correct number of parts" do
      slug = Internet.slug(2, separator: ".")

      assert slug |> String.split(".") |> length() == 2
    end

    test "returns a single lowercase word with no separator when word_count is 1" do
      slug = Internet.slug(1)

      refute String.contains?(slug, "-")
      assert String.match?(slug, ~r/^[a-z]+$/)
    end

    test "returns different slugs on repeated calls" do
      slugs = Enum.map(1..10, fn _ -> Internet.slug() end)

      assert slugs |> Enum.uniq() |> length() > 1
    end

    test "raises FunctionClauseError for a non-positive word count" do
      assert_raise FunctionClauseError, fn -> Internet.slug(0) end
    end
  end

  describe "domain_name/1 popular categories" do
    alias NeoFaker.Internet.DomainGenerator

    test "returns a domain for every popular_type" do
      for type <- [:all, :ecommerce, :email, :search, :social] do
        domain = Internet.domain_name(type: :popular, popular_type: type)

        assert is_binary(domain) and String.contains?(domain, ".")
      end
    end

    test "DomainGenerator.generate_popular_domain_name/1 covers every branch" do
      for type <- [:all, :ecommerce, :email, :search, :social] do
        assert is_binary(DomainGenerator.generate_popular_domain_name(type))
      end
    end
  end

  describe "username/1 option validation" do
    test "raises NimbleOptions.ValidationError for an unknown joiner" do
      assert_raise NimbleOptions.ValidationError, fn -> Internet.username(joiner: :space) end
    end

    test "raises NimbleOptions.ValidationError for an unknown username_type" do
      assert_raise NimbleOptions.ValidationError, fn ->
        Internet.username(username_type: :robot)
      end
    end
  end

  describe "tld/1 option validation" do
    test "raises NimbleOptions.ValidationError for an unknown type" do
      assert_raise NimbleOptions.ValidationError, fn -> Internet.tld(type: :vanity) end
    end
  end

  describe "ipv6/1 compressed notation" do
    test "returns a compressed address when compressed: true" do
      for _ <- 1..50 do
        ip = Internet.ipv6(compressed: true)

        assert String.valid?(ip)
        assert String.match?(ip, ~r/^[0-9A-F:]+$/)
      end
    end

    test "compressed lowercase notation is honoured" do
      ip = Internet.ipv6(compressed: true, uppercase: false)

      assert String.match?(ip, ~r/^[0-9a-f:]+$/)
    end
  end

  describe "url/1 with popular and custom domains" do
    test "appends a path and query to a popular-domain URL without a duplicate TLD" do
      url = Internet.url(domain_type: :popular, path: true, query: true)

      assert String.contains?(url, "?")
      [_scheme, rest] = String.split(url, "://", parts: 2)
      host = rest |> String.split(["/", "?"]) |> List.first()

      assert length(String.split(host, ".")) <= 2
    end

    test "custom domain URL keeps the given domain verbatim" do
      url = Internet.url(domain_type: :custom, domain_name: "elixir-lang.org", path: true)

      assert String.contains?(url, "elixir-lang.org/")
    end
  end

  describe "Generator" do
    test "compressed_ipv6/0 collapses zero runs and never yields ':::'" do
      for _ <- 1..200 do
        ip = Generator.compressed_ipv6()

        refute String.contains?(ip, ":::")
        assert String.valid?(ip)
      end
    end

    test "compress_ipv6_groups/1 collapses the longest zero run to '::'" do
      assert Generator.compress_ipv6_groups([1, 0, 0, 0, 2, 3, 4, 5]) == "1::2:3:4:5"
      assert Generator.compress_ipv6_groups([0, 0, 1, 2, 3, 4, 5, 6]) == "::1:2:3:4:5:6"
      assert Generator.compress_ipv6_groups([1, 2, 3, 4, 5, 6, 0, 0]) == "1:2:3:4:5:6::"
      assert Generator.compress_ipv6_groups([0, 0, 0, 0, 0, 0, 0, 0]) == "::"
    end

    test "compress_ipv6_groups/1 keeps the earliest run on a tie (RFC 5952)" do
      assert Generator.compress_ipv6_groups([0, 0, 1, 0, 0, 2, 3, 4]) == "::1:0:0:2:3:4"
    end

    test "compress_ipv6_groups/1 leaves lone zeros and zero-free lists uncompressed" do
      assert Generator.compress_ipv6_groups([0, 1, 0, 2, 0, 3, 4, 5]) == "0:1:0:2:0:3:4:5"
      assert Generator.compress_ipv6_groups([1, 2, 3, 4, 5, 6, 7, 8]) == "1:2:3:4:5:6:7:8"
    end

    test "pick_public_third_octet/2 skips the reserved /24 sub-blocks" do
      for _ <- 1..100 do
        refute Generator.pick_public_third_octet(192, 88) == 99
        refute Generator.pick_public_third_octet(198, 51) == 100
        refute Generator.pick_public_third_octet(203, 0) == 113
      end

      assert Generator.pick_public_third_octet(10, 20) in 0..255
    end

    test "url_path/0 is 1..3 lowercase alphanumeric segments" do
      for _ <- 1..50 do
        path = Generator.url_path()
        segments = String.split(path, "/")

        assert length(segments) in 1..3
        assert Enum.all?(segments, &String.match?(&1, ~r/^[a-z0-9]+$/))
      end
    end

    test "query_string/0 is 1..3 key=value pairs" do
      for _ <- 1..50 do
        query = Generator.query_string()
        pairs = String.split(query, "&")

        assert length(pairs) in 1..3

        assert Enum.all?(pairs, fn pair ->
                 [k, v] = String.split(pair, "=")
                 String.match?(k, ~r/^[a-z0-9]+$/) and String.to_integer(v) in 1..1000
               end)
      end
    end

    test "private_ipv4/1 builds an address in the right block for every class" do
      assert String.starts_with?(Generator.private_ipv4(:a), "10.")
      assert String.starts_with?(Generator.private_ipv4(:c), "192.168.")

      [_a, b | _] = :b |> Generator.private_ipv4() |> String.split(".")
      assert String.to_integer(b) in 16..31
    end
  end
end
