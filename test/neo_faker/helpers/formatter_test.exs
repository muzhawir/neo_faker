defmodule NeoFaker.Helpers.FormatterTest do
  use ExUnit.Case, async: true

  alias NeoFaker.Helpers.Formatter

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
