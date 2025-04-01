defmodule NeoFaker.PersonTest do
  use ExUnit.Case, async: true

  alias NeoFaker.Helper.Generator
  alias NeoFaker.Person
  alias NeoFaker.Person.Util

  @module NeoFaker.Person

  describe "first_name/1" do
    test "returns a first name" do
      assert Person.first_name() in Util.unisex_name(@module, "first_names")
    end

    test "returns a first name with option" do
      male_names = Util.unisex_name(@module, "first_names", locale: :id_id)

      assert Person.first_name(sex: :male, locale: :id_id) in male_names
    end
  end

  describe "middle_name/1" do
    test "returns a middle name" do
      assert Person.middle_name() in Util.unisex_name(@module, "middle_names")
    end

    test "returns a middle name with option" do
      female_names = Util.unisex_name(@module, "middle_names", locale: :id_id)

      assert Person.middle_name(sex: :female, locale: :id_id) in female_names
    end
  end

  describe "last_name/1" do
    test "returns a last name" do
      assert Person.last_name() in Util.unisex_name(@module, "last_names")
    end

    test "returns a last name with option" do
      unisex_names = Util.unisex_name(@module, "last_names", locale: :id_id)

      assert Person.last_name(locale: :id_id) in unisex_names
    end
  end

  describe "prefix/1" do
    test "returns a prefix" do
      assert Person.prefix() in Generator.fetch_data(@module, "name_affixes.exs", key: "prefixes")
    end

    test "returns a local prefix" do
      prefixes =
        Generator.fetch_data(@module, "name_affixes.exs", key: "prefixes", locale: :id_id)

      assert Person.prefix(locale: "id_id") in prefixes
    end
  end

  describe "suffix/1" do
    test "returns a suffix" do
      assert Person.suffix() in Generator.fetch_data(@module, "name_affixes.exs", key: "suffixes")
    end

    test "returns a local suffix" do
      suffixes =
        Generator.fetch_data(@module, "name_affixes.exs", key: "suffixes", locale: :id_id)

      assert Person.suffix(locale: :id_id) in suffixes
    end
  end

  describe "age/2" do
    test "returns a random age" do
      assert Person.age() in 0..120
    end
  end

  describe "binary_gender/1" do
    test "returns a binary gender" do
      assert Person.binary_gender() in Generator.fetch_data(@module, "gender.exs", key: "binary")
    end

    test "returns a binary gender with option" do
      binary_gender = Generator.fetch_data(@module, "gender.exs", key: "binary", locale: :id_id)

      assert Person.binary_gender(locale: :id_id) in binary_gender
    end
  end

  describe "short_binary_gender/1" do
    test "returns a short binary gender" do
      short_binary_gender = Generator.fetch_data(@module, "gender.exs", key: "short_binary")

      assert Person.short_binary_gender() in short_binary_gender
    end
  end

  describe "non_binary_gender/1" do
    test "returns a non binary gender" do
      non_binary_gender = Generator.fetch_data(@module, "gender.exs", key: "non_binary")

      assert Person.non_binary_gender() in non_binary_gender
    end

    test "returns a non binary gender with option" do
      non_binary_gender =
        Generator.fetch_data(
          @module,
          "gender.exs",
          key: "non_binary",
          locale: :id_id
        )

      assert Person.non_binary_gender(locale: :id_id) in non_binary_gender
    end
  end
end
