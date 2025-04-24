defmodule NeoFaker.PersonTest do
  use ExUnit.Case, async: true

  import NeoFaker.Data.Cache, only: [fetch_cache!: 3]

  alias NeoFaker.Person

  @module NeoFaker.Person

  defp valid_name?(name), do: is_binary(name) and String.valid?(name) and name != ""

  defp generate_word_list(locale, module, file) do
    locale |> fetch_cache!(module, file) |> Map.values() |> List.flatten()
  end

  describe "first_name/1" do
    test "returns a first name" do
      assert valid_name?(Person.first_name())
    end

    test "returns a first name with option" do
      assert valid_name?(Person.first_name(sex: :male, locale: :id_id))
    end
  end

  describe "middle_name/1" do
    test "returns a middle name" do
      assert valid_name?(Person.middle_name())
    end

    test "returns a middle name with option" do
      assert valid_name?(Person.middle_name(sex: :female, locale: :id_id))
    end
  end

  describe "last_name/1" do
    test "returns a last name" do
      assert valid_name?(Person.last_name())
    end

    test "returns a last name with option" do
      assert valid_name?(Person.last_name(locale: :id_id))
    end
  end

  describe "prefix/1" do
    test "returns a prefix" do
      word_list = generate_word_list(:default, @module, "name_affixes.exs")

      assert Person.prefix(locale: :default) in word_list
    end

    test "returns a local prefix" do
      word_list = generate_word_list(:id_id, @module, "name_affixes.exs")

      assert Person.prefix(locale: :id_id) in word_list
    end
  end

  describe "suffix/1" do
    test "returns a suffix" do
      word_list = generate_word_list(:default, @module, "name_affixes.exs")

      assert Person.suffix(locale: :default) in word_list
    end

    test "returns a local suffix" do
      word_list = generate_word_list(:id_id, @module, "name_affixes.exs")

      assert Person.suffix(locale: :id_id) in word_list
    end
  end

  describe "age/2" do
    test "returns a random age", do: assert(Person.age() in 0..120)
  end

  describe "binary_gender/1" do
    test "returns a binary gender" do
      world_list = generate_word_list(:default, @module, "gender.exs")

      assert Person.binary_gender(locale: :default) in world_list
    end

    test "returns a binary gender with option" do
      word_list = generate_word_list(:id_id, @module, "gender.exs")

      assert Person.binary_gender(locale: :id_id) in word_list
    end
  end

  describe "short_binary_gender/1" do
    test "returns a short binary gender" do
      word_list = generate_word_list(:default, @module, "gender.exs")

      assert Person.short_binary_gender(locale: :default) in word_list
    end
  end

  describe "non_binary_gender/1" do
    test "returns a non binary gender" do
      word_list = generate_word_list(:default, @module, "gender.exs")

      assert Person.non_binary_gender(locale: :default) in word_list
    end

    test "returns a non binary gender with option" do
      word_list = generate_word_list(:id_id, @module, "gender.exs")

      assert Person.non_binary_gender(locale: :id_id) in word_list
    end
  end
end
