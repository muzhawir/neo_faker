defmodule NeoFaker.BloodTest do
  use ExUnit.Case, async: true

  alias NeoFaker.Blood

  describe "group/0" do
    test "returns a full blood type with Rh factor" do
      assert Blood.group() in ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"]
    end
  end

  describe "type/0" do
    test "returns a blood type name" do
      assert Blood.type() in ["A", "B", "AB", "O"]
    end
  end

  describe "rh_factor/0" do
    test "returns a random Rh factor" do
      assert Blood.rh_factor() in ["+", "-"]
    end
  end
end
