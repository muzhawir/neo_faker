defmodule NeoFaker.Locales.EnUs.PersonTest do
  use ExUnit.Case, async: true

  alias NeoFaker.Locales.EnUs.Person
  alias NeoFaker.Locales.EnUs.Person.Generator

  @ssn_regexp ~r/^\d{3}-\d{2}-\d{4}$/

  describe "ssn/0" do
    test "returns a valid SSN in AAA-GG-SSSS format" do
      for _ <- 1..100 do
        assert Regex.match?(@ssn_regexp, Person.ssn())
      end
    end
  end

  describe "Generator" do
    test "serial_number/2 zero-pads to the requested width" do
      for _ <- 1..200 do
        assert String.match?(Generator.serial_number(99, 2), ~r/^\d{2}$/)
        assert String.match?(Generator.serial_number(9999, 4), ~r/^\d{4}$/)
      end
    end

    test "area_number/0 is a 3-digit string, never 000, 666, or 900+" do
      # 666 is drawn with probability 1/899 per call; 20k draws exercises the
      # "666 -> 777" substitution branch with near-certainty while a real 666
      # must never leak through.
      results = for _ <- 1..20_000, do: Generator.area_number()

      assert Enum.all?(results, &String.match?(&1, ~r/^\d{3}$/))
      refute "666" in results
      refute "000" in results
      refute Enum.any?(results, fn n -> String.to_integer(n) >= 900 end)
    end
  end
end
