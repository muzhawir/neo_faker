defmodule NeoFaker.DateTest do
  use ExUnit.Case, async: true

  alias NeoFaker.Date, as: FakeDate

  describe "add/2" do
    test "returns a random date in Date format" do
      assert FakeDate.add(0..0) == Date.utc_today()
    end

    test "returns a random date in ISO 8601 format" do
      assert FakeDate.add(0..0, format: :iso8601) == Date.to_iso8601(Date.utc_today())
    end
  end
end
