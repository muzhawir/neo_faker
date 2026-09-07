defmodule NeoFaker.Locales.IdId.PersonTest do
  use ExUnit.Case, async: true

  alias NeoFaker.Locales.IdId.Person
  alias NeoFaker.Locales.IdId.Person.Generator

  @sixteen_digits ~r/^\d{16}$/

  describe "nik/0" do
    test "returns a 16-digit numeric string" do
      for _ <- 1..50 do
        nik = Person.nik()

        assert is_binary(nik)
        assert String.match?(nik, @sixteen_digits)
      end
    end
  end

  describe "npwp/0" do
    test "delegates to nik/0 and returns a 16-digit numeric string" do
      for _ <- 1..50 do
        assert String.match?(Person.npwp(), @sixteen_digits)
      end
    end
  end

  describe "Generator" do
    test "serial_number/2 zero-pads to the requested width" do
      for _ <- 1..100 do
        assert String.match?(Generator.serial_number(79, 2), ~r/^\d{2}$/)
        assert String.match?(Generator.serial_number(9999, 4), ~r/^\d{4}$/)
      end
    end

    test "birth_date/0 is a 6-digit DDMMYY string, covering the female day+40 code" do
      results = for _ <- 1..500, do: Generator.birth_date()

      assert Enum.all?(results, &String.match?(&1, ~r/^\d{6}$/))

      days =
        Enum.map(results, fn <<d::binary-size(2), _rest::binary>> -> String.to_integer(d) end)

      assert Enum.any?(days, &(&1 > 40)), "expected at least one female-coded day (day + 40)"
      assert Enum.any?(days, &(&1 <= 31)), "expected at least one plain day"
    end
  end
end
