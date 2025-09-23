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
end
