defmodule NeoFaker.CryptoTest do
  use ExUnit.Case, async: true

  alias NeoFaker.Crypto

  defp assert_hash(hash, expected_length) do
    assert is_binary(hash)
    assert String.valid?(hash)
    assert String.length(hash) == expected_length
  end

  describe "md5/0" do
    test "returns a valid MD5 hash of 32 hex characters" do
      assert_hash(Crypto.md5(), 32)
    end

    test "returns a lowercase hex string" do
      assert String.match?(Crypto.md5(), ~r/^[0-9a-f]{32}$/)
    end
  end

  describe "sha1/0" do
    test "returns a valid SHA-1 hash of 40 hex characters" do
      assert_hash(Crypto.sha1(), 40)
    end

    test "returns a lowercase hex string" do
      assert String.match?(Crypto.sha1(), ~r/^[0-9a-f]{40}$/)
    end
  end

  describe "sha256/0" do
    test "returns a valid SHA-256 hash of 64 hex characters" do
      assert_hash(Crypto.sha256(), 64)
    end

    test "returns a lowercase hex string" do
      assert String.match?(Crypto.sha256(), ~r/^[0-9a-f]{64}$/)
    end
  end
end
