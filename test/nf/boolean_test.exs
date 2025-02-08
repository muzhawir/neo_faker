defmodule Nf.BooleanTest do
  use ExUnit.Case, async: true

  describe "value" do
    test "returns a boolean value" do
      assert Nf.Boolean.boolean() in [true, false]
    end

    test "returns a boolean value with true_ratio" do
      assert Nf.Boolean.boolean(50) in [true, false]
    end
  end
end
