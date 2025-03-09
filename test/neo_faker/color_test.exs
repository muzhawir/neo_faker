defmodule NeoFaker.ColorTest do
  use ExUnit.Case, async: true

  alias NeoFaker.Color

  @cmyk_format_regexp ~r/^cmyk\((\d{1,3})%, (\d{1,3})%, (\d{1,3})%, (\d{1,3})%\)$/
  @hex_format_regexp ~r/^#([A-Fa-f0-9]{3}|[A-Fa-f0-9]{4}|[A-Fa-f0-9]{6}|[A-Fa-f0-9]{8})$/
  @hsl_format_regexp ~r/^hsl\((\d{1,3}), (\d{1,3})%, (\d{1,3})%\)$/
  @hsla_format_regexp ~r/^hsla?\((\d{1,3}), (\d{1,3})%, (\d{1,3})%(?:, ([01](?:\.\d+)?)?)?\)$/

  describe "cmyk/1" do
    test "returns a CMYK color in tuple format" do
      cmyk_color = Color.cmyk()

      assert is_tuple(cmyk_color)

      assert tuple_size(cmyk_color) == 4

      assert Enum.all?(Tuple.to_list(cmyk_color), &is_integer/1)
    end

    test "returns a CMYK color in W3C format" do
      assert Regex.match?(@cmyk_format_regexp, Color.cmyk(format: :w3c))
    end
  end

  describe "hex/1" do
    test "returns a HEX color in string format" do
      assert Regex.match?(@hex_format_regexp, Color.hex())
    end

    test "returns a HEX color with options" do
      digit = [:three_digit, :four_digit, :eight_digit]

      for format <- digit do
        assert Regex.match?(@hex_format_regexp, Color.hex(format: format))
      end
    end
  end

  describe "hsl/1" do
    test "returns a HSL color in tuple format" do
      hsl_color = Color.hsl()

      assert is_tuple(hsl_color)

      assert tuple_size(hsl_color) == 3

      assert Enum.all?(Tuple.to_list(hsl_color), &is_integer/1)
    end

    test "returns a HSL color in W3C format" do
      assert Regex.match?(@hsl_format_regexp, Color.hsl(format: :w3c))
    end
  end

  describe "hsla/1" do
    test "returns a HSLA color in tuple format" do
      hsla_color = Color.hsla()

      assert is_tuple(hsla_color)

      assert tuple_size(hsla_color) == 4

      assert Enum.all?(Tuple.to_list(hsla_color), &is_number/1)
    end

    test "returns a HSLA color in W3C format" do
      assert Regex.match?(@hsla_format_regexp, Color.hsla(format: :w3c))
    end
  end
end
