defmodule NeoFaker.PersonTest do
  use ExUnit.Case, async: true

  alias NeoFaker.Helper.Locale
  alias NeoFaker.Person

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

  describe "short_binary_gender/1" do
    test "returns random short binary gender" do
      assert Person.short_binary_gender() in ["M", "F"]
    end
  end

  describe "non_binary_gender/1" do
    test "returns random non-binary gender" do
      gender_lists = Locale.load_cache("person", "gender.exs", "non_binary")

      assert Person.non_binary_gender() in gender_lists
    end
  end
end
