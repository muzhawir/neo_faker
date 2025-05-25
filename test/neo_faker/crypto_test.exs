defmodule NeoFaker.CryptoTest do
  use ExUnit.Case, async: true

  defp assert_hash(hash, expected_length) do
    assert String.valid?(hash)
    assert String.length(hash) == expected_length
  end

  describe "md5/1" do
    test "returns a MD5 hash" do
      assert_hash(NeoFaker.Crypto.md5(), 32)
    end
  end

  describe "sha1/1" do
    test "returns a SHA-1 hash" do
      assert_hash(NeoFaker.Crypto.sha1(), 40)
    end
  end

  describe "sha256/1" do
    test "returns a SHA-256 hash" do
      assert_hash(NeoFaker.Crypto.sha256(), 64)
    end
  end
end
