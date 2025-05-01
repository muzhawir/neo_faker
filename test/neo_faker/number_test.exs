defmodule NeoFaker.NumberTest do
  use ExUnit.Case, async: true

  alias NeoFaker.Number

  describe "between/2" do
    test "returns a random number between min and max" do
      assert is_integer(Number.between())
    end

    test "returns a random float between min and max" do
      assert is_float(Number.between(1.0, 100.0))
    end
  end

  describe "decimal/2" do
    test "returns random floating-point number" do
      assert is_float(Number.float())
    end

    test "returns random floating-point number with specified range" do
      assert is_float(Number.float(1..100, 100..1000))
    end
  end

  describe "digit/0" do
    test "Generates a random digit between 0 and 9" do
      digit = Number.digit()

      assert is_integer(digit) and digit in 0..9
    end
  end
end
