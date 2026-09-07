defmodule NeoFaker.Helpers.FormatterTest do
  use ExUnit.Case, async: true

  alias NeoFaker.Helpers.Formatter

  describe "format_date/2" do
    test "returns the Date struct unchanged for :struct" do
      assert Formatter.format_date(~D[2025-03-25], :struct) == ~D[2025-03-25]
    end

    test "returns an ISO 8601 string for :iso8601" do
      assert Formatter.format_date(~D[2025-03-25], :iso8601) == "2025-03-25"
    end
  end

  describe "format_time/2" do
    test "returns the Time struct unchanged for :struct" do
      assert Formatter.format_time(~T[15:22:10], :struct) == ~T[15:22:10]
    end

    test "returns an ISO 8601 string for :iso8601" do
      assert Formatter.format_time(~T[15:22:10], :iso8601) == "15:22:10"
    end
  end

  describe "format_number/2" do
    test "converts an integer to a string" do
      assert Formatter.format_number(42, :string) == "42"
    end

    test "converts a float to a string" do
      assert Formatter.format_number(42.5, :string) == "42.5"
    end

    test "returns an integer unchanged for :integer" do
      assert Formatter.format_number(42, :integer) == 42
    end

    test "truncates a float toward zero for :integer" do
      assert Formatter.format_number(2.9, :integer) == 2
    end
  end

  describe "format_boolean/2" do
    test "returns the boolean unchanged for :boolean" do
      assert Formatter.format_boolean(true, :boolean) == true
      assert Formatter.format_boolean(false, :boolean) == false
    end

    test "maps true and false to 1 and 0 for :integer" do
      assert Formatter.format_boolean(true, :integer) == 1
      assert Formatter.format_boolean(false, :integer) == 0
    end
  end

  describe "apply_case/2" do
    test "uppercases for :upper" do
      assert Formatter.apply_case("Hello", :upper) == "HELLO"
    end

    test "lowercases for :lower" do
      assert Formatter.apply_case("Hello", :lower) == "hello"
    end

    test "returns the string unchanged for :none" do
      assert Formatter.apply_case("Hello", :none) == "Hello"
    end
  end

  describe "slugify/1" do
    test "downcases and drops every non-alphanumeric character" do
      assert Formatter.slugify("T-shirt") == "tshirt"
      assert Formatter.slugify("o'clock") == "oclock"
      assert Formatter.slugify("long-term") == "longterm"
      assert Formatter.slugify("ice cream") == "icecream"
      assert Formatter.slugify("José") == "jos"
    end

    test "leaves an already-bare lowercase token unchanged" do
      assert Formatter.slugify("computer") == "computer"
      assert Formatter.slugify("web2") == "web2"
    end

    test "result is always a bare [a-z0-9] token" do
      for word <- ~w[Hello WORLD a-b c.d e_f g/h "quote" 42Answer], word != "" do
        assert Formatter.slugify(word) =~ ~r/^[a-z0-9]*$/
      end
    end
  end
end
