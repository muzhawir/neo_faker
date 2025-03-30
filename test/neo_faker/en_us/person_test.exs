defmodule NeoFaker.EnUs.PersonTest do
  use ExUnit.Case, async: true

  alias NeoFaker.EnUs.Person

  @ssn_regexp ~r/^\d{3}-\d{2}-\d{4}$/

  describe "ssn/0" do
    test "returns a random SSN" do
      ssn = Person.ssn()

      assert is_binary(ssn) and Regex.match?(@ssn_regexp, ssn)
    end
  end
end
