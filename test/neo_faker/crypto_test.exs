defmodule NeoFaker.CryptoTest do
  use ExUnit.Case, async: true

  alias NeoFaker.Crypto
  alias NeoFaker.Crypto.Validator

  @hash_lengths %{md5: 32, sha1: 40, sha256: 64, sha512: 128}

  # Launders a value to an opaque type so the compiler's type checker does not
  # narrow it, letting us reach the runtime guard clauses that exist for
  # arbitrary external input.
  defp opaque(term), do: Enum.random([term])

  defp assert_hash(hash, expected_length) do
    assert is_binary(hash)
    assert String.valid?(hash)
    assert String.length(hash) == expected_length
  end

  describe "md5/1" do
    test "returns a lowercase 32-char hex string by default" do
      assert_hash(Crypto.md5(), 32)
      assert String.match?(Crypto.md5(), ~r/^[0-9a-f]{32}$/)
    end

    test "returns an uppercase hex string when case: :upper" do
      assert String.match?(Crypto.md5(case: :upper), ~r/^[0-9A-F]{32}$/)
    end

    test "raises NimbleOptions.ValidationError for an unknown :case" do
      assert_raise NimbleOptions.ValidationError, fn -> Crypto.md5(case: :mixed) end
    end
  end

  describe "sha1/1" do
    test "returns a lowercase 40-char hex string by default" do
      assert String.match?(Crypto.sha1(), ~r/^[0-9a-f]{40}$/)
    end

    test "returns an uppercase hex string when case: :upper" do
      assert String.match?(Crypto.sha1(case: :upper), ~r/^[0-9A-F]{40}$/)
    end
  end

  describe "sha256/1" do
    test "returns a lowercase 64-char hex string by default" do
      assert String.match?(Crypto.sha256(), ~r/^[0-9a-f]{64}$/)
    end

    test "returns an uppercase hex string when case: :upper" do
      assert String.match?(Crypto.sha256(case: :upper), ~r/^[0-9A-F]{64}$/)
    end
  end

  describe "sha512/1" do
    test "returns a lowercase 128-char hex string by default" do
      assert String.match?(Crypto.sha512(), ~r/^[0-9a-f]{128}$/)
    end

    test "returns an uppercase hex string when case: :upper" do
      assert String.match?(Crypto.sha512(case: :upper), ~r/^[0-9A-F]{128}$/)
    end
  end

  describe "hash/2" do
    test "dispatches to the right algorithm for every supported type" do
      for {type, length} <- @hash_lengths do
        assert_hash(Crypto.hash(type), length)
      end
    end

    test "honours the :case option" do
      assert String.match?(Crypto.hash(:sha256, case: :upper), ~r/^[0-9A-F]{64}$/)
      assert String.match?(Crypto.hash(:sha256, case: :lower), ~r/^[0-9a-f]{64}$/)
    end

    test "raises ArgumentError for an unsupported hash type" do
      assert_raise ArgumentError, ~r/Invalid hash type/, fn -> Crypto.hash(opaque(:sha3)) end
    end

    test "raises ArgumentError for a non-atom hash type" do
      assert_raise ArgumentError, ~r/Invalid hash type/, fn -> Crypto.hash(opaque("md5")) end
    end

    test "returns a different hash on repeated calls" do
      assert Crypto.hash(:md5) != Crypto.hash(:md5)
    end
  end

  describe "token/2" do
    test "returns a URL-safe base64 token by default" do
      token = Crypto.token()

      assert is_binary(token)
      assert String.match?(token, ~r/^[A-Za-z0-9_-]+$/)
    end

    test "the length argument controls the number of random bytes, not the string length" do
      # base64 without padding: 8 bytes -> 11 chars
      assert String.length(Crypto.token(8)) == 11
    end

    test "returns a lowercase hex token when encoding: :hex" do
      token = Crypto.token(16, encoding: :hex)

      assert String.match?(token, ~r/^[0-9a-f]{32}$/)
    end

    test "returns a different token on repeated calls" do
      assert Crypto.token() != Crypto.token()
    end

    test "raises ArgumentError when length is zero or negative" do
      assert_raise ArgumentError, ~r/length must be a positive integer/, fn -> Crypto.token(0) end

      assert_raise ArgumentError, ~r/length must be a positive integer/, fn ->
        Crypto.token(-5)
      end
    end

    test "raises ArgumentError when length is not an integer" do
      assert_raise ArgumentError, ~r/length must be a positive integer/, fn ->
        Crypto.token(:big)
      end
    end

    test "raises NimbleOptions.ValidationError for an unknown encoding" do
      assert_raise NimbleOptions.ValidationError, fn -> Crypto.token(16, encoding: :base32) end
    end
  end

  describe "uuid/1" do
    @standard_regexp ~r/^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/
    @compact_regexp ~r/^[0-9a-f]{8}[0-9a-f]{4}4[0-9a-f]{3}[89ab][0-9a-f]{15}$/

    test "returns a standard lowercase UUID v4 by default" do
      assert String.match?(Crypto.uuid(), @standard_regexp)
    end

    test "returns a compact UUID when format: :compact" do
      uuid = Crypto.uuid(format: :compact)

      refute String.contains?(uuid, "-")
      assert String.match?(uuid, @compact_regexp)
    end

    test "returns an uppercase UUID when case: :upper" do
      uuid = Crypto.uuid(case: :upper)

      assert uuid == String.upcase(uuid)
      assert String.match?(String.downcase(uuid), @standard_regexp)
    end

    test "combines format and case options" do
      uuid = Crypto.uuid(format: :compact, case: :upper)

      refute String.contains?(uuid, "-")
      assert uuid == String.upcase(uuid)
    end

    test "returns a different UUID on repeated calls" do
      assert Crypto.uuid() != Crypto.uuid()
    end

    test "raises NimbleOptions.ValidationError for an unknown format" do
      assert_raise NimbleOptions.ValidationError, fn -> Crypto.uuid(format: :urn) end
    end
  end

  describe "HashGenerator.generate_hash/2" do
    alias NeoFaker.Crypto.HashGenerator

    test "defaults to lowercase when called without options" do
      assert String.match?(HashGenerator.generate_hash(:md5), ~r/^[0-9a-f]{32}$/)
    end

    test "honours an explicit case option" do
      assert String.match?(HashGenerator.generate_hash(:sha256, case: :upper), ~r/^[0-9A-F]{64}$/)
    end
  end

  describe "Validator.validate_hash_type!/1" do
    test "returns :ok for every supported type" do
      for type <- [:md5, :sha1, :sha256, :sha512] do
        assert Validator.validate_hash_type!(type) == :ok
      end
    end

    test "raises ArgumentError for an unsupported type" do
      assert_raise ArgumentError, ~r/Expected one of \[:md5, :sha1, :sha256, :sha512\]/, fn ->
        Validator.validate_hash_type!(:whirlpool)
      end
    end
  end
end
