defmodule NeoFaker.Locales.IdId.PersonTest do
  use ExUnit.Case, async: true

  alias NeoFaker.Locales.IdId.Person

  describe "nik/0" do
    test "returns a NIK as a binary string" do
      assert is_binary(Person.nik())
    end

    test "returns a NIK with exactly 16 characters" do
      assert String.length(Person.nik()) == 16
    end

    test "returns a NIK containing only digits" do
      assert String.match?(Person.nik(), ~r/^\d{16}$/)
    end
  end
end
