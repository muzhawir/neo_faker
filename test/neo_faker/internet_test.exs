defmodule NeoFaker.InternetTest do
  use ExUnit.Case, async: true

  alias NeoFaker.Internet

  describe "username/1" do
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
    test "returns a single random word by default" do
      domain = Internet.domain_name()

      assert is_binary(domain)
      assert String.match?(domain, ~r/^[a-z]+$/)
    end

    test "returns multiple words joined by dash when word_count > 1" do
      domain = Internet.domain_name(word_count: 3)

      assert is_binary(domain)
      assert domain |> String.split("-") |> length() == 3
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

    test "raises ArgumentError for an unknown type" do
      assert_raise ArgumentError, fn ->
        Internet.domain_name(type: :unknown)
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
      email = Internet.email(username_type: :word, domain_type: :popular, popular_type: :email)

      assert String.match?(email, ~r/^[a-zA-Z0-9_.-]+@[a-zA-Z0-9_.-]+\.[a-z]+$/)
    end
  end

  describe "ipv4/0" do
    test "returns a valid IPv4 address" do
      ip = Internet.ipv4()
      parts = String.split(ip, ".")

      assert length(parts) == 4

      assert Enum.all?(parts, fn part ->
               case Integer.parse(part) do
                 {num, ""} -> num >= 0 and num <= 255
                 _ -> false
               end
             end)
    end

    test "returns a publicly routable address (not loopback, private, or reserved)" do
      for _ <- 1..50 do
        ip = Internet.ipv4()
        [a, b, c, _d] = ip |> String.split(".") |> Enum.map(&String.to_integer/1)

        # 0.x.x.x — "This" network
        refute a == 0, "#{ip}: first octet must not be 0"
        # 10.x.x.x — RFC 1918 private class A
        refute a == 10, "#{ip}: must not be in 10.0.0.0/8"
        # 100.64.0.0/10 — carrier-grade NAT (RFC 6598)
        refute a == 100 and b in 64..127, "#{ip}: must not be in 100.64.0.0/10"
        # 127.x.x.x — loopback
        refute a == 127, "#{ip}: must not be in 127.0.0.0/8"
        # 169.254.x.x — link-local (RFC 3927)
        refute a == 169 and b == 254, "#{ip}: must not be in 169.254.0.0/16"
        # 172.16.0.0/12 — RFC 1918 private class B
        refute a == 172 and b in 16..31, "#{ip}: must not be in 172.16.0.0/12"
        # 192.0.0.x — IETF protocol assignments
        refute a == 192 and b == 0 and c == 0, "#{ip}: must not be in 192.0.0.0/24"
        # 192.0.2.x — TEST-NET-1 (RFC 5737)
        refute a == 192 and b == 0 and c == 2, "#{ip}: must not be in 192.0.2.0/24"
        # 192.88.99.x — deprecated 6to4 relay anycast (RFC 7526)
        refute a == 192 and b == 88 and c == 99, "#{ip}: must not be in 192.88.99.0/24"
        # 192.168.x.x — RFC 1918 private class C
        refute a == 192 and b == 168, "#{ip}: must not be in 192.168.0.0/16"
        # 198.18.0.0/15 — benchmarking (RFC 2544)
        refute a == 198 and b in 18..19, "#{ip}: must not be in 198.18.0.0/15"
        # 198.51.100.x — TEST-NET-2 (RFC 5737)
        refute a == 198 and b == 51 and c == 100, "#{ip}: must not be in 198.51.100.0/24"
        # 203.0.113.x — TEST-NET-3 (RFC 5737)
        refute a == 203 and b == 0 and c == 113, "#{ip}: must not be in 203.0.113.0/24"
        # 224.x.x.x–239.x.x.x — multicast
        refute a in 224..239, "#{ip}: must not be in multicast range 224.0.0.0/4"
        # 240.x.x.x–255.x.x.x — reserved / broadcast
        refute a in 240..255, "#{ip}: must not be in reserved range 240.0.0.0/4"
      end
    end

    test "returns a private IPv4 address when private: true" do
      ip = Internet.ipv4(private: true)
      [a, b, _c, _d] = ip |> String.split(".") |> Enum.map(&String.to_integer/1)

      assert a == 10 or (a == 172 and b in 16..31) or (a == 192 and b == 168),
             "#{ip}: expected a private RFC 1918 address"
    end

    test "returns a class A private address when private: true, class: :a" do
      ip = Internet.ipv4(private: true, class: :a)

      assert String.starts_with?(ip, "10.")
    end

    test "returns a class B private address when private: true, class: :b" do
      ip = Internet.ipv4(private: true, class: :b)
      [_a, b | _] = ip |> String.split(".") |> Enum.map(&String.to_integer/1)

      assert String.starts_with?(ip, "172.")
      assert b in 16..31
    end

    test "returns a class C private address when private: true, class: :c" do
      ip = Internet.ipv4(private: true, class: :c)

      assert String.starts_with?(ip, "192.168.")
    end

    test "raises ArgumentError for an invalid class" do
      assert_raise ArgumentError, fn ->
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

    test "raises ArgumentError for an invalid protocol" do
      assert_raise ArgumentError, fn ->
        Internet.url(protocol: :ftp)
      end
    end

    test "raises ArgumentError for an invalid domain_type" do
      assert_raise ArgumentError, fn ->
        Internet.url(domain_type: :unknown)
      end
    end
  end

  describe "slug/2" do
    test "returns a slug with 3 dash-separated words by default" do
      slug = Internet.slug()

      assert slug |> String.split("-") |> length() == 3
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
  end
end
