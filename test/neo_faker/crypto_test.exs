defmodule NeoFaker.CryptoTest do
  use ExUnit.Case, async: true

  describe "md5/1" do
    test "returns a MD5 hash" do
      md5 = NeoFaker.Crypto.md5()
      valid_string? = String.valid?(md5)
      valid_length? = String.length(md5) == 32

      assert valid_string? and valid_length?
    end
  end

  describe "sha1/1" do
    test "returns a SHA-1 hash" do
      sha1 = NeoFaker.Crypto.sha1()
      valid_string? = String.valid?(sha1)
      valid_length? = String.length(sha1) == 40

      assert valid_string? and valid_length?
    end
  end

  describe "sha256/1" do
    test "returns a SHA-256 hash" do
      sha256 = NeoFaker.Crypto.sha256()
      valid_string? = String.valid?(sha256)
      valid_length? = String.length(sha256) == 64

      assert valid_string? and valid_length?
    end
  end
end
