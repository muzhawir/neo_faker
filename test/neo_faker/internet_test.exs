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

    test "returns a user_name with the specified separator" do
      Enum.each(%{dot: ".", underscore: "_", dash: "-"}, fn {key, val} ->
        username = Internet.user_name(separator: key)

        assert String.contains?(username, val)
      end)

      assert [separator: :all] |> Internet.user_name() |> String.contains?([".", "_", "-"])
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
end
