defmodule NeoFaker.NumberTest do
  use ExUnit.Case, async: true

  alias NeoFaker.Number

  describe "between/2" do
    test "returns a random number between min and max" do
      integer = Number.between()

      assert is_integer(integer)
    end

    test "returns a random float between min and max" do
      float = Number.between(1.0, 100.0)

      assert is_float(float)
    end
  end

  describe "decimal/2" do
    test "returns a random decimal" do
      decimal = Number.decimal()

      assert is_float(decimal)
    end
  end
end
