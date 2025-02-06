defmodule NeoFaker.HashTest do
  use ExUnit.Case

  describe "md5/0" do
    test "returns a md5 hash" do
      md5 = NeoFaker.Hash.md5()
      assert String.length(md5) == 32
    end
  end

  describe "sha1/0" do
    test "returns a sha1 hash" do
      sha1 = NeoFaker.Hash.sha1()
      assert String.length(sha1) == 40
    end
  end

  describe "sha256/0" do
    test "returns a sha256 hash" do
      sha256 = NeoFaker.Hash.sha256()
      assert String.length(sha256) == 64
    end
  end
end
