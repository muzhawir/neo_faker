defmodule NeoFaker.BloodTest do
  use ExUnit.Case, async: true

  describe "group/0" do
    test "returns a blood type in full format with rh factor" do
      full_format = NeoFaker.Blood.group()
      blood_types = ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"]

      assert full_format in blood_types
    end
  end

  describe "type/0" do
    test "returns a blood type name" do
      assert NeoFaker.Blood.type() in ["A", "B", "AB", "O"]
    end
  end

  describe "rh_factor/0" do
    test "returns a random rh factor" do
      assert NeoFaker.Blood.rh_factor() in ["+", "-"]
    end
  end
end
