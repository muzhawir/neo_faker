defmodule NeoFaker.TextTest do
  use ExUnit.Case, async: true

  alias NeoFaker.Text

  @alphanumeric_regexp ~r/[a-zA-Z0-9]/

  describe "character/1" do
    test "returns a single random character" do
      assert Text.character() =~ @alphanumeric_regexp
    end

    test "returns a single random character with option" do
      options = [:alphabet_lower, :alphabet_upper, :alphabet, :digit]

      for option <- options do
        assert Text.character(type: option) =~ @alphanumeric_regexp
      end
    end
  end
end
