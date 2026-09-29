defmodule NeoFaker.ColorTest do
  use ExUnit.Case, async: true

  alias NeoFaker.Color
  alias NeoFaker.Data

  @module Color
  @cmyk_regexp ~r/^device-cmyk\(\d{1,3}% \d{1,3}% \d{1,3}% \d{1,3}%\)$/
  @hex_regexp ~r/^#([A-Fa-f0-9]{3}|[A-Fa-f0-9]{4}|[A-Fa-f0-9]{6}|[A-Fa-f0-9]{8})$/
  @hsl_regexp ~r/^hsl\(\d{1,3}, \d{1,3}%, \d{1,3}%\)$/
  @hsla_regexp ~r/^hsla\(\d{1,3}, \d{1,3}%, \d{1,3}%, [01](\.\d)?\)$/
  @rgb_regexp ~r/^rgb\(\d{1,3}, \d{1,3}, \d{1,3}\)$/
  @rgba_regexp ~r/^rgba\(\d{1,3}, \d{1,3}, \d{1,3}, [01](\.\d)?\)$/

  defp opaque(term), do: Enum.random([term])

  defp keyword_cache(locale) do
    locale |> Data.fetch!(@module, "keyword.exs") |> Map.values() |> List.flatten()
  end

  defp assert_tuple_of(value, size, type_fun) do
    assert is_tuple(value)
    assert tuple_size(value) == size
    assert Enum.all?(Tuple.to_list(value), type_fun)
  end

  describe "cmyk/0" do
    test "returns a 4-integer tuple in 0..100" do
      assert_tuple_of(Color.cmyk(), 4, &(&1 in 0..100))
    end
  end

  describe "hsl/0" do
    test "returns a {hue, saturation, lightness} tuple in range" do
      {h, s, l} = Color.hsl()

      assert h in 0..359
      assert s in 0..100 and l in 0..100
    end
  end

  describe "hsla/0" do
    test "returns a 4-element tuple with a float alpha" do
      {h, s, l, a} = Color.hsla()

      assert h in 0..359
      assert s in 0..100 and l in 0..100
      assert is_float(a) and a >= 0.0 and a <= 1.0
    end
  end

  describe "rgb/0" do
    test "returns a 3-integer tuple in 0..255" do
      assert_tuple_of(Color.rgb(), 3, &(&1 in 0..255))
    end
  end

  describe "rgba/0" do
    test "returns a 4-element tuple with a float alpha" do
      {r, g, b, a} = Color.rgba()

      assert Enum.all?([r, g, b], &(&1 in 0..255))
      assert is_float(a) and a >= 0.0 and a <= 1.0
    end
  end

  describe "css/1" do
    test "returns each notation in its CSS syntax" do
      for _ <- 1..20 do
        assert Regex.match?(@hex_regexp, Color.css(:hex))
        assert Regex.match?(@rgb_regexp, Color.css(:rgb))
        assert Regex.match?(@rgba_regexp, Color.css(:rgba))
        assert Regex.match?(@hsl_regexp, Color.css(:hsl))
        assert Regex.match?(@hsla_regexp, Color.css(:hsla))
        assert Regex.match?(@cmyk_regexp, Color.css(:cmyk))
      end
    end

    test "uses a six-digit hex code for :hex" do
      assert String.length(Color.css(:hex)) == 7
    end

    test "returns a string in a web notation by default, never device-cmyk" do
      web = [@hex_regexp, @rgb_regexp, @rgba_regexp, @hsl_regexp, @hsla_regexp]

      for _ <- 1..100 do
        result = Color.css()

        assert Enum.any?(web, &Regex.match?(&1, result))
        refute String.starts_with?(result, "device-cmyk")
      end
    end

    test "treats :random like the default" do
      assert is_binary(Color.css(:random))
    end

    test "raises ArgumentError for an unknown notation" do
      assert_raise ArgumentError, ~r/invalid CSS notation :lab/, fn ->
        Color.css(opaque(:lab))
      end
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
end
