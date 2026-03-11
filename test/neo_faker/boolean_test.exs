defmodule NeoFaker.BooleanTest do
  use ExUnit.Case, async: true

  alias NeoFaker.Boolean

  describe "boolean/2" do
    test "returns a boolean value with default ratio" do
      assert Boolean.boolean() in [true, false]
    end

    test "returns a boolean value with explicit true_ratio" do
      assert Boolean.boolean(50) in [true, false]
    end

    test "returns an integer value when integer: true" do
      assert Boolean.boolean(50, integer: true) in [1, 0]
    end

    test "returns false when true_ratio is 0" do
      assert Boolean.boolean(0) == false
    end

    test "returns true when true_ratio is 100" do
      assert Boolean.boolean(100) == true
    end

    test "returns 0 when true_ratio is 0 and integer: true" do
      assert Boolean.boolean(0, integer: true) == 0
    end

    test "returns 1 when true_ratio is 100 and integer: true" do
      assert Boolean.boolean(100, integer: true) == 1
    end
  end
end
