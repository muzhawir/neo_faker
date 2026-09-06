defmodule NeoFaker.EnUs.PersonTest do
  use ExUnit.Case, async: true

  alias NeoFaker.EnUs.Person

  @ssn_regexp ~r/^\d{3}-\d{2}-\d{4}$/

  describe "ssn/0" do
    test "returns a valid SSN as a binary string" do
      ssn = Person.ssn()

      assert is_binary(ssn)
      assert String.valid?(ssn)
    end

    test "returns a SSN matching the XXX-XX-XXXX format" do
      assert Regex.match?(@ssn_regexp, Person.ssn())
    end
  end
end
