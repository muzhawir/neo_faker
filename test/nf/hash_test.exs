defmodule Nf.HashTest do
  use ExUnit.Case

  describe "md5/0" do
    test "returns a MD5 hash" do
      md5 = Nf.Hash.md5()
      valid_string? = String.valid?(md5)
      valid_length? = String.length(md5) == 32

      assert Enum.all?([valid_string?, valid_length?])
    end
  end

  describe "sha1/0" do
    test "returns a SHA-1 hash" do
      sha1 = Nf.Hash.sha1()
      valid_string? = String.valid?(sha1)
      valid_length? = String.length(sha1) == 40

      assert Enum.all?([valid_string?, valid_length?])
    end
  end

  describe "sha256/0" do
    test "returns a SHA-256 hash" do
      sha256 = Nf.Hash.sha256()
      valid_string? = String.valid?(sha256)
      valid_length? = String.length(sha256) == 64

      assert Enum.all?([valid_string?, valid_length?])
    end
  end
end
