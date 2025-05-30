defmodule NeoFaker.AddressTest do
  use ExUnit.Case, async: true

  describe "building_number/2" do
    test "returns a random integer building number" do
      assert is_integer(NeoFaker.Address.building_number(1..100, type: :integer))
    end

    test "return a random string building number" do
      assert is_binary(NeoFaker.Address.building_number(1..100, type: :string))
    end

    test "return a random integer building number with specific range" do
      assert NeoFaker.Address.building_number(1..100, type: :integer) in 1..100
    end
  end
end
