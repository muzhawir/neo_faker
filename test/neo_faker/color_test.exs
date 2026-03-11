defmodule NeoFaker.ColorTest do
  use ExUnit.Case, async: true

  alias NeoFaker.Color
  alias NeoFaker.Data

  @module Color
  @cmyk_format_regexp ~r/^cmyk\((\d{1,3})%, (\d{1,3})%, (\d{1,3})%, (\d{1,3})%\)$/
  @hex_format_regexp ~r/^#([A-Fa-f0-9]{3}|[A-Fa-f0-9]{4}|[A-Fa-f0-9]{6}|[A-Fa-f0-9]{8})$/
  @hsl_format_regexp ~r/^hsl\((\d{1,3}), (\d{1,3})%, (\d{1,3})%\)$/
  @hsla_format_regexp ~r/^hsla?\((\d{1,3}), (\d{1,3})%, (\d{1,3})%(?:, ([01](?:\.\d+)?)?)?\)$/
  @rgb_format_regexp ~r/^rgb\((\d{1,3}), (\d{1,3}), (\d{1,3})\)$/
  @rgba_format_regexp ~r/^rgba?\((\d{1,3}), (\d{1,3}), (\d{1,3})(?:, ([01](?:\.\d+)?)?)?\)$/

  defp fetch_color_keyword_cache!(locale) do
    locale
    |> Data.fetch!(@module, "keyword.exs")
    |> Map.values()
    |> List.flatten()
  end

  defp assert_tuple_of(value, size, type_fun) do
    assert is_tuple(value)
    assert tuple_size(value) == size
    assert Enum.all?(Tuple.to_list(value), type_fun)
  end

  describe "cmyk/1" do
    test "returns a CMYK color as a 4-integer tuple" do
      assert_tuple_of(Color.cmyk(), 4, &is_integer/1)
    end

    test "returns a CMYK color in W3C string format" do
      assert Regex.match?(@cmyk_format_regexp, Color.cmyk(format: :w3c))
    end
  end

  describe "hex/1" do
    test "returns a HEX color as a valid string" do
      assert Regex.match?(@hex_format_regexp, Color.hex())
    end

    test "returns a HEX color for each supported format option" do
      for format <- [:three_digit, :four_digit, :eight_digit] do
        assert Regex.match?(@hex_format_regexp, Color.hex(format: format))
      end
    end
  end

  describe "hsl/1" do
    test "returns an HSL color as a 3-integer tuple" do
      assert_tuple_of(Color.hsl(), 3, &is_integer/1)
    end

    test "returns an HSL color in W3C string format" do
      assert Regex.match?(@hsl_format_regexp, Color.hsl(format: :w3c))
    end
  end

  describe "hsla/1" do
    test "returns an HSLA color as a 4-element tuple of numbers" do
      assert_tuple_of(Color.hsla(), 4, &is_number/1)
    end

    test "returns an HSLA color in W3C string format" do
      assert Regex.match?(@hsla_format_regexp, Color.hsla(format: :w3c))
    end
  end

  describe "keyword/1" do
    test "returns a color keyword from the default locale" do
      assert Color.keyword() in fetch_color_keyword_cache!(:default)
    end

    test "returns a color keyword for each supported category" do
      for category <- [:basic, :extended] do
        assert Color.keyword(category: category) in fetch_color_keyword_cache!(:default)
      end
    end

    test "returns a color keyword from the id_id locale" do
      assert Color.keyword(locale: :id_id) in fetch_color_keyword_cache!(:id_id)
    end
  end

  describe "rgb/1" do
    test "returns an RGB color as a 3-integer tuple" do
      assert_tuple_of(Color.rgb(), 3, &is_integer/1)
    end

    test "returns an RGB color in W3C string format" do
      assert Regex.match?(@rgb_format_regexp, Color.rgb(format: :w3c))
    end
  end

  describe "rgba/1" do
    test "returns an RGBA color as a 4-element tuple of numbers" do
      assert_tuple_of(Color.rgba(), 4, &is_number/1)
    end

    test "returns an RGBA color in W3C string format" do
      assert Regex.match?(@rgba_format_regexp, Color.rgba(format: :w3c))
    end
  end
end
