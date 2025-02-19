defmodule NeoFaker.BooleanTest do
  use ExUnit.Case, async: true

  describe "value" do
    test "returns a boolean value" do
      assert NeoFaker.Boolean.boolean() in [true, false]
    end

    test "returns a boolean value with true_ratio" do
      assert NeoFaker.Boolean.boolean(50) in [true, false]
    end
  end
end
