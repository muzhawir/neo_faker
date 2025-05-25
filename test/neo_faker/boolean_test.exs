defmodule NeoFaker.BooleanTest do
  use ExUnit.Case, async: true

  describe "boolean/2" do
    test "returns a boolean value" do
      assert NeoFaker.Boolean.boolean() in [true, false]
    end

    test "returns a boolean value with true_ratio" do
      assert NeoFaker.Boolean.boolean(50) in [true, false]
    end

    test "returns a boolean value with integer" do
      assert NeoFaker.Boolean.boolean(50, integer: true) in [1, 0]
    end

    test "returns false for true_ratio = 0" do
      assert NeoFaker.Boolean.boolean(0) == false
    end

    test "returns true for true_ratio = 100" do
      assert NeoFaker.Boolean.boolean(100) == true
    end

    test "returns 0 for true_ratio = 0 with integer option" do
      assert NeoFaker.Boolean.boolean(0, integer: true) == 0
    end

    test "returns 1 for true_ratio = 100 with integer option" do
      assert NeoFaker.Boolean.boolean(100, integer: true) == 1
    end
  end
end
