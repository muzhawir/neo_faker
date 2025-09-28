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

    test "returns a username with appended number and specific range" do
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

    test "returns a custom domain name when type: :custom and domain_name is provided" do
      domain = Internet.domain_name(type: :custom, domain_name: "elixir-lang.org")
      assert domain == "elixir-lang.org"
    end

    test "returns default custom domain when type: :custom and domain_name is not provided" do
      domain = Internet.domain_name(type: :custom)
      assert domain == "example.com"
    end

    test "returns a random word for unknown type" do
      domain = Internet.domain_name(type: :unknown)
      assert is_binary(domain)
      assert String.match?(domain, ~r/^[a-z]+$/)
    end
  end

  describe "tld/1" do
    test "returns a TLD with a dot by default" do
      tld = Internet.tld()

      assert String.starts_with?(tld, ".") && String.valid?(tld)
    end

    test "returns a TLD without a dot when :dot option is false" do
      tld = Internet.tld(dot: false)

      assert not String.starts_with?(tld, ".") && String.valid?(tld)
    end

    test "returns a TLD with specified type" do
      Enum.each([:all, :safe, :generic, :sponsored, :country_code], fn type ->
        tld = Internet.tld(type: type)

        assert String.starts_with?(tld, ".") && String.valid?(tld)
      end)
    end
  end

  describe "email/1" do
    test "returns a valid email address with default options (random domain)" do
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

      assert String.ends_with?(email, "@elixir-lang.org") or
               String.match?(email, ~r/^[^@]+@elixir-lang\.org$/)
    end

    test "returns a valid email address with custom domain type and no domain_name" do
      email = Internet.email(domain_type: :custom)

      assert String.ends_with?(email, "@example.com") or
               String.match?(email, ~r/^[^@]+@example\.com$/)
    end

    test "returns a valid email address with custom username and domain options" do
      email = Internet.email(username_type: :word, domain_type: :popular, popular_type: :email)
      assert String.match?(email, ~r/^[a-zA-Z0-9_.-]+@[a-zA-Z0-9_.-]+\.[a-z]+$/)
    end
  end

  test "ipv4/0" do
    ip = Internet.ipv4()
    parts = String.split(ip, ".")

    assert length(parts) == 4

    assert Enum.all?(parts, fn part ->
             case Integer.parse(part) do
               {num, ""} -> num >= 0 and num <= 254
               _ -> false
             end
           end)
  end

  describe "ipv6/1" do
    test "returns an IPv6 address in uppercase by default" do
      ip = Internet.ipv6()
      assert String.match?(ip, ~r/^([0-9A-F]{1,4}:){7}[0-9A-F]{1,4}$/)
    end

    test "returns an IPv6 address in lowercase when :uppercase is false" do
      ip = Internet.ipv6(uppercase: false)
      assert String.match?(ip, ~r/^([0-9a-f]{1,4}:){7}[0-9a-f]{1,4}$/)
    end

    test "returns an IPv6 address with correct format and length" do
      ip = Internet.ipv6()
      assert ip |> String.split(":") |> length() == 8
      assert String.length(ip) >= 15
    end
  end

  describe "mac_address/1" do
    test "returns a MAC address in uppercase by default" do
      mac = Internet.mac_address()
      assert String.match?(mac, ~r/^([0-9A-F]{2}:){5}[0-9A-F]{2}$/)
    end

    test "returns a MAC address in lowercase when :uppercase is false" do
      mac = Internet.mac_address(uppercase: false)
      assert String.match?(mac, ~r/^([0-9a-f]{2}:){5}[0-9a-f]{2}$/)
    end

    test "returns a MAC address with correct format and length" do
      mac = Internet.mac_address()
      assert String.length(mac) == 17
      assert mac |> String.split(":") |> length() == 6
    end
  end
end
