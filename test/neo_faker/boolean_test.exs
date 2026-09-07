defmodule NeoFaker.BooleanTest do
  use ExUnit.Case, async: true

  alias NeoFaker.Boolean
  alias NeoFaker.Boolean.Generator

  describe "boolean/1" do
    test "returns a boolean with the default ratio" do
      assert Boolean.boolean() in [true, false]
    end

    test "always returns false for a 0 ratio" do
      assert Boolean.boolean(0) == false
    end

    test "always returns true for a 100 ratio" do
      assert Boolean.boolean(100) == true
    end

    test "raises ArgumentError when true_ratio is outside 0..100" do
      assert_raise ArgumentError, ~r/true_ratio must be between 0 and 100/, fn ->
        Boolean.boolean(101)
      end

      assert_raise ArgumentError, ~r/true_ratio must be between 0 and 100/, fn ->
        Boolean.boolean(-1)
      end
    end
  end

  describe "Generator.boolean/1" do
    test "is deterministic at the extremes" do
      assert Generator.boolean(100) == true
      assert Generator.boolean(0) == false
    end
  end
end
