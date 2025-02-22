defmodule NeoFaker.PersonTest do
  use ExUnit.Case, async: true

  alias NeoFaker.Helper.Locale
  alias NeoFaker.Person
  alias NeoFaker.Person.Utils

  @module NeoFaker.Person

  describe "age/2" do
    test "returns random age" do
      assert Person.age(7, 44) in 7..44
    end
  end

  describe "binary_gender/1" do
    test "returns random binary gender" do
      assert Person.binary_gender() in ["Male", "Female"]
    end
  end

  describe "first_name/1" do
    test "returns random first name" do
      first_names = Utils.load_all_random_names(@module, "first_names")

      assert Person.first_name() in first_names
    end

    test "returns random first name in unisex, masculine, or feminine" do
      first_names = Utils.load_all_random_names(@module, "first_names")

      unisex_first_names = Person.first_name(type: :unisex) in first_names
      masculine_first_names = Person.first_name(type: :masculine) in first_names
      feminine_first_names = Person.first_name(type: :feminine) in first_names

      assert Enum.all?([unisex_first_names, masculine_first_names, feminine_first_names])
    end
  end

  describe "last_name/1" do
    test "returns random last name" do
      last_names = Utils.load_all_random_names(@module, "last_names")

      assert Person.last_name() in last_names
    end

    test "returns random last name in unisex, masculine, or feminine" do
      last_names = Utils.load_all_random_names(@module, "last_names")

      unisex_last_names = Person.last_name(type: :unisex) in last_names
      masculine_last_names = Person.last_name(type: :masculine) in last_names
      feminine_last_names = Person.last_name(type: :feminine) in last_names

      assert Enum.all?([unisex_last_names, masculine_last_names, feminine_last_names])
    end
  end

  describe "middle_name/1" do
    test "returns random middle name" do
      middle_names = Utils.load_all_random_names(@module, "middle_names")

      assert Person.middle_name() in middle_names
    end

    test "returns random middle name in unisex, masculine, or feminine" do
      middle_names = Utils.load_all_random_names(@module, "middle_names")

      unisex_middle_names = Person.middle_name(type: :unisex) in middle_names
      masculine_middle_names = Person.middle_name(type: :masculine) in middle_names
      feminine_middle_names = Person.middle_name(type: :feminine) in middle_names

      assert Enum.all?([unisex_middle_names, masculine_middle_names, feminine_middle_names])
    end
  end

  describe "non_binary_gender/1" do
    test "returns random non-binary gender" do
      gender_lists = Locale.load_persistent_term("person", "gender.exs", "non_binary")

      assert Person.non_binary_gender() in gender_lists
    end
  end

  describe "prefix/0" do
  end

  describe "short_binary_gender/1" do
    test "returns random short binary gender" do
      assert Person.short_binary_gender() in ["M", "F"]
    end
  end

  describe "suffix/0" do
  end
end
