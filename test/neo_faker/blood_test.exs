defmodule NeoFaker.BloodTest do
  use ExUnit.Case

  describe "full_format/0" do
    test "returns a full format blood type" do
      full_format = NeoFaker.Blood.full_format()
      blood_types = ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"]

      assert full_format in blood_types
    end
  end
end
