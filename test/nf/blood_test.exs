defmodule Nf.BloodTest do
  use ExUnit.Case

  describe "group/0" do
    test "returns a full format blood type" do
      full_format = Nf.Blood.group()
      blood_types = ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"]

      assert full_format in blood_types
    end
  end

  describe "type/0" do
    test "returns a blood type" do
      assert Nf.Blood.type() in ["A", "B", "AB", "O"]
    end
  end

  describe "rh_factor/0" do
    test "returns a rh factor" do
      assert Nf.Blood.rh_factor() in ["+", "-"]
    end
  end
end
