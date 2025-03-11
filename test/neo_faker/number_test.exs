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
    test "returns random floating-point number" do
      decimal = Number.float()

      assert is_float(decimal)
    end

    test "returns random floating-point number with specified range" do
      decimal = Number.float(1..100, 100..1000)

      assert is_float(decimal)
    end
  end

  describe "digit/0" do
    test "Generates a random digit between 0 and 9" do
      digit = Number.digit()

      assert is_integer(digit) and digit in 0..9
    end
  end
end
