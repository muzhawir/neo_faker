defmodule NeoFaker.IdId.PersonTest do
  use ExUnit.Case, async: true

  alias NeoFaker.IdId.Person

  describe "nik/0" do
    test "returns a random NIK" do
      assert is_binary(Person.nik()) && String.length(Person.nik()) == 16
    end
  end
end
