defmodule NeoFaker.PersonTest do
  use ExUnit.Case, async: true

  alias NeoFaker.Data
  alias NeoFaker.Person

  @module Person

  defp valid_name?(name), do: is_binary(name) and String.valid?(name) and name != ""

  defp fetch_word_list(locale, file) do
    locale |> Data.fetch!(@module, file) |> Map.values() |> List.flatten()
  end

  describe "first_name/1" do
    test "returns a valid first name" do
      assert valid_name?(Person.first_name())
    end

    test "returns a valid first name with sex and locale options" do
      assert valid_name?(Person.first_name(sex: :male, locale: :id_id))
    end
  end

  describe "middle_name/1" do
    test "returns a valid middle name" do
      assert valid_name?(Person.middle_name())
    end

    test "returns a valid middle name with sex and locale options" do
      assert valid_name?(Person.middle_name(sex: :female, locale: :id_id))
    end
  end

  describe "last_name/1" do
    test "returns a valid last name" do
      assert valid_name?(Person.last_name())
    end

    test "returns a valid last name with locale option" do
      assert valid_name?(Person.last_name(locale: :id_id))
    end
  end

  describe "prefix/1" do
    test "returns a prefix from the default locale word list" do
      word_list = fetch_word_list(:default, "name_affixes.exs")

      assert Person.prefix(locale: :default) in word_list
    end

    test "returns a prefix from the id_id locale word list" do
      word_list = fetch_word_list(:id_id, "name_affixes.exs")

      assert Person.prefix(locale: :id_id) in word_list
    end
  end

  describe "suffix/1" do
    test "returns a suffix from the default locale word list" do
      word_list = fetch_word_list(:default, "name_affixes.exs")

      assert Person.suffix(locale: :default) in word_list
    end

    test "returns a suffix from the id_id locale word list" do
      word_list = fetch_word_list(:id_id, "name_affixes.exs")

      assert Person.suffix(locale: :id_id) in word_list
    end
  end

  describe "age/2" do
    test "returns a random integer age between 0 and 120" do
      assert Person.age() in 0..120
    end
  end

  describe "binary_gender/1" do
    test "returns a binary gender from the default locale word list" do
      word_list = fetch_word_list(:default, "gender.exs")

      assert Person.binary_gender(locale: :default) in word_list
    end

    test "returns a binary gender from the id_id locale word list" do
      word_list = fetch_word_list(:id_id, "gender.exs")

      assert Person.binary_gender(locale: :id_id) in word_list
    end
  end

  describe "short_binary_gender/1" do
    test "returns a short binary gender as a non-empty string" do
      result = Person.short_binary_gender(locale: :default)

      assert is_binary(result)
      assert String.valid?(result)
      assert result != ""
    end

    test "returns a short binary gender with a single uppercase letter" do
      result = Person.short_binary_gender(locale: :default)

      assert String.match?(result, ~r/^[A-Z]$/)
    end
  end

  describe "non_binary_gender/1" do
    test "returns a non-binary gender from the default locale word list" do
      word_list = fetch_word_list(:default, "gender.exs")

      assert Person.non_binary_gender(locale: :default) in word_list
    end

    test "returns a non-binary gender from the id_id locale word list" do
      word_list = fetch_word_list(:id_id, "gender.exs")

      assert Person.non_binary_gender(locale: :id_id) in word_list
    end
  end
end
