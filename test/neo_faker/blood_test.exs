defmodule NeoFaker.BloodTest do
  use ExUnit.Case, async: true

  alias NeoFaker.Blood
  alias NeoFaker.Blood.Generator

  @types ["A", "B", "AB", "O"]
  @rh_factors ["+", "-"]
  @groups for t <- ["A", "B", "AB", "O"], r <- ["+", "-"], do: t <> r

  describe "group/1" do
    test "returns a full blood group by default" do
      assert Blood.group() in @groups
    end

    test "returns only the ABO type when format: :type_only" do
      assert Blood.group(format: :type_only) in @types
    end

    test "returns only the Rh factor when format: :rh_only" do
      assert Blood.group(format: :rh_only) in @rh_factors
    end

    test "raises NimbleOptions.ValidationError for an unknown format" do
      assert_raise NimbleOptions.ValidationError, fn -> Blood.group(format: :full) end
    end
  end

  describe "type/0" do
    test "returns one of the four ABO types" do
      assert Blood.type() in @types
    end
  end

  describe "rh_factor/0" do
    test "returns a plus or minus sign" do
      assert Blood.rh_factor() in @rh_factors
    end
  end

  describe "medical_notation/1" do
    test "returns the compact \"X positive/negative\" form by default" do
      for _ <- 1..50 do
        notation = Blood.medical_notation()

        assert notation in for(t <- @types, s <- ["positive", "negative"], do: "#{t} #{s}")
      end
    end

    test "returns the verbose \"Type X, Rh Y\" form when verbose: true" do
      for _ <- 1..50 do
        notation = Blood.medical_notation(verbose: true)

        assert notation in for(
                 t <- @types,
                 s <- ["positive", "negative"],
                 do: "Type #{t}, Rh #{s}"
               )
      end
    end

    test "raises NimbleOptions.ValidationError for a non-boolean :verbose" do
      assert_raise NimbleOptions.ValidationError, fn -> Blood.medical_notation(verbose: :yes) end
    end
  end

  describe "all_types/0" do
    test "returns exactly the four ABO types in canonical order" do
      assert Blood.all_types() == @types
    end
  end

  describe "all_rh_factors/0" do
    test "returns both Rh factors" do
      assert Blood.all_rh_factors() == @rh_factors
    end
  end

  describe "Generator" do
    test "type/0 and rh_factor/0 draw from the fixed lists" do
      assert Generator.type() in @types
      assert Generator.rh_factor() in @rh_factors
    end

    test "all_types/0 and all_rh_factors/0 mirror the public API" do
      assert Generator.all_types() == @types
      assert Generator.all_rh_factors() == @rh_factors
    end
  end
end
