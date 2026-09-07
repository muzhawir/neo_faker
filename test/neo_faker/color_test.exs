defmodule NeoFaker.ColorTest do
  use ExUnit.Case, async: true

  alias NeoFaker.Color
  alias NeoFaker.Data

  @module Color
  @cmyk_regexp ~r/^cmyk\(\d{1,3}%, \d{1,3}%, \d{1,3}%, \d{1,3}%\)$/
  @hex_regexp ~r/^#([A-Fa-f0-9]{3}|[A-Fa-f0-9]{4}|[A-Fa-f0-9]{6}|[A-Fa-f0-9]{8})$/
  @hsl_regexp ~r/^hsl\(\d{1,3}, \d{1,3}%, \d{1,3}%\)$/
  @hsla_regexp ~r/^hsla\(\d{1,3}, \d{1,3}%, \d{1,3}%, [01](\.\d)?\)$/
  @rgb_regexp ~r/^rgb\(\d{1,3}, \d{1,3}, \d{1,3}\)$/
  @rgba_regexp ~r/^rgba\(\d{1,3}, \d{1,3}, \d{1,3}, [01](\.\d)?\)$/

  defp keyword_cache(locale) do
    locale |> Data.fetch!(@module, "keyword.exs") |> Map.values() |> List.flatten()
  end

  defp assert_tuple_of(value, size, type_fun) do
    assert is_tuple(value)
    assert tuple_size(value) == size
    assert Enum.all?(Tuple.to_list(value), type_fun)
  end

  describe "cmyk/1" do
    test "returns a 4-integer tuple in 0..100 by default" do
      assert_tuple_of(Color.cmyk(), 4, &(&1 in 0..100))
    end

    test "returns a W3C string when format: :w3c" do
      assert Regex.match?(@cmyk_regexp, Color.cmyk(format: :w3c))
    end
  end

  describe "hex/1" do
    test "returns a six-digit hex string by default" do
      hex = Color.hex()

      assert Regex.match?(@hex_regexp, hex)
      assert String.length(hex) == 7
    end

    test "returns the requested digit length for every format" do
      lengths = %{three_digit: 4, four_digit: 5, six_digit: 7, eight_digit: 9}

      for {format, length} <- lengths do
        assert String.length(Color.hex(format: format)) == length
      end
    end

    test "raises NimbleOptions.ValidationError for an unknown format" do
      assert_raise NimbleOptions.ValidationError, fn -> Color.hex(format: :two_digit) end
    end
  end

  describe "hsl/1" do
    test "returns a 3-integer tuple by default" do
      assert_tuple_of(Color.hsl(), 3, &is_integer/1)
    end

    test "returns a W3C string when format: :w3c" do
      assert Regex.match?(@hsl_regexp, Color.hsl(format: :w3c))
    end
  end

  describe "hsla/1" do
    test "returns a 4-element tuple of numbers with a float alpha by default" do
      {h, s, l, a} = Color.hsla()

      assert Enum.all?([h, s, l], &is_integer/1)
      assert is_float(a) and a >= 0.0 and a <= 1.0
    end

    test "returns a W3C string when format: :w3c" do
      assert Regex.match?(@hsla_regexp, Color.hsla(format: :w3c))
    end
  end

  describe "keyword/1" do
    test "returns a keyword colour from the default locale" do
      assert Color.keyword() in keyword_cache(:default)
    end

    test "returns a keyword colour for every category" do
      for category <- [:all, :basic, :extended] do
        assert Color.keyword(category: category) in keyword_cache(:default)
      end
    end

    test "returns a locale-specific keyword colour" do
      assert Color.keyword(locale: :id_id) in keyword_cache(:id_id)
    end

    test "raises NimbleOptions.ValidationError for an unknown category" do
      assert_raise NimbleOptions.ValidationError, fn -> Color.keyword(category: :muted) end
    end
  end

  describe "rgb/1" do
    test "returns a 3-integer tuple in 0..255 by default" do
      assert_tuple_of(Color.rgb(), 3, &(&1 in 0..255))
    end

    test "returns a W3C string when format: :w3c" do
      assert Regex.match?(@rgb_regexp, Color.rgb(format: :w3c))
    end
  end

  describe "rgba/1" do
    test "returns a 4-element tuple with a float alpha by default" do
      {r, g, b, a} = Color.rgba()

      assert Enum.all?([r, g, b], &(&1 in 0..255))
      assert is_float(a) and a >= 0.0 and a <= 1.0
    end

    test "returns a W3C string when format: :w3c" do
      assert Regex.match?(@rgba_regexp, Color.rgba(format: :w3c))
    end
  end

  describe "random/1" do
    test "returns a tuple or a hex string when no options are given" do
      for _ <- 1..50 do
        result = Color.random()

        assert is_tuple(result) or Regex.match?(@hex_regexp, result)
      end
    end

    test "restricts the pool to W3C-capable formats when format: :w3c" do
      w3c_regexps = [@cmyk_regexp, @hsl_regexp, @hsla_regexp, @rgb_regexp, @rgba_regexp]

      for _ <- 1..50 do
        result = Color.random(format: :w3c)

        assert is_binary(result)
        assert Enum.any?(w3c_regexps, &Regex.match?(&1, result))
      end
    end

    test "a non-:w3c format falls through to the per-generator branch" do
      # The individual generators only accept their own format values, so an
      # arbitrary format passed to random/1 surfaces as a validation error.
      assert_raise NimbleOptions.ValidationError, fn -> Color.random(format: :six_digit) end
    end
  end
end
