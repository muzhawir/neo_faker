defmodule Nf.PersonTest do
  use ExUnit.Case, async: true

  describe "age/2" do
    test "returns random age" do
      assert Nf.Person.age(7, 44) in 7..44
    end
  end

  describe "binary_gender/1" do
    test "returns random binary gender" do
      assert Nf.Person.binary_gender() in ["Male", "Female"]
    end

    test "returns both random binary gender" do
      assert Nf.Person.binary_gender(2) in [["Male", "Female"], ["Female", "Male"]]
    end
  end

  describe "short_binary_gender/1" do
    test "returns random short binary gender" do
      assert Nf.Person.short_binary_gender() in ["M", "F"]
    end

    test "returns both random short binary gender" do
      assert Nf.Person.short_binary_gender(2) in [["M", "F"], ["F", "M"]]
    end
  end

  describe "non_binary_gender/1" do
    test "returns random non-binary gender" do
      gender_lists = Nf.Helper.load_cache("person", "gender.exs", "non_binary")

      assert Nf.Person.non_binary_gender() in gender_lists
    end

    test "returns both random non-binary gender" do
      gender_lists = Nf.Helper.load_cache("person", "gender.exs", "non_binary")
      gender_result = Nf.Person.non_binary_gender(2)

      assert Enum.all?(gender_result, &(&1 in gender_lists))
    end
  end
end
