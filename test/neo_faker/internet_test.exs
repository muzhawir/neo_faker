defmodule NeoFaker.InternetTest do
  use ExUnit.Case, async: true

  alias NeoFaker.Internet

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

  describe "user_name/1" do
    test "returns a user_name with the specified word count" do
      user_name = Internet.user_name(word_count: 3)

      assert user_name |> String.split([".", "-", "_"]) |> length() == 3
    end

    test "returns a user_name with the specified joiner" do
      Enum.each(%{dot: ".", underscore: "_", dash: "-"}, fn {key, val} ->
        username = Internet.user_name(joiner: key)

        assert String.contains?(username, val)
      end)

      assert [joiner: :all] |> Internet.user_name() |> String.contains?([".", "_", "-"])
    end

    test "returns a user_name with the specified username type" do
      Enum.each([:person, :word], fn type ->
        user_name = Internet.user_name(username_type: type)

        assert String.contains?(user_name, [".", "-", "_"]) && String.valid?(user_name)
      end)
    end

    test "returns a user_name with appended number and specific range" do
      extracted_number =
        [number: true, number_range: 100..200]
        |> Internet.user_name()
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
      assert String.split(domain, "-") |> length() == 3
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

  test "ipv4/0" do
    ip = NeoFaker.Internet.ipv4()
    parts = String.split(ip, ".")

    assert length(parts) == 4

    assert Enum.all?(parts, fn part ->
      case Integer.parse(part) do
        {num, ""} -> num >= 0 and num <= 254
        _ -> false
      end
    end)
  end
end
