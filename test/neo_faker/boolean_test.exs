defmodule NeoFaker.BooleanTest do
  use ExUnit.Case, async: true

  alias NeoFaker.Boolean
  alias NeoFaker.Boolean.Generator

  describe "boolean/2" do
    test "returns a boolean with the default ratio" do
      assert Boolean.boolean() in [true, false]
    end

    test "returns an integer when integer: true" do
      assert Boolean.boolean(50, integer: true) in [1, 0]
    end

    test "always returns false (or 0) for a 0 ratio" do
      assert Boolean.boolean(0) == false
      assert Boolean.boolean(0, integer: true) == 0
    end

    test "always returns true (or 1) for a 100 ratio" do
      assert Boolean.boolean(100) == true
      assert Boolean.boolean(100, integer: true) == 1
    end

    test "raises ArgumentError when true_ratio is outside 0..100" do
      assert_raise ArgumentError, ~r/true_ratio must be between 0 and 100/, fn ->
        Boolean.boolean(101)
      end

      assert_raise ArgumentError, ~r/true_ratio must be between 0 and 100/, fn ->
        Boolean.boolean(-1)
      end
    end

    test "raises NimbleOptions.ValidationError for a non-boolean :integer option" do
      assert_raise NimbleOptions.ValidationError, fn -> Boolean.boolean(50, integer: :yes) end
    end
  end

  describe "Generator.boolean/1" do
    test "is deterministic at the extremes" do
      assert Generator.boolean(100) == true
      assert Generator.boolean(0) == false
    end
  end
end
