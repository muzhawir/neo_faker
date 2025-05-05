defmodule NeoFaker.Color do
  @moduledoc """
  Functions for generating random colors.

  This module provides utilities to generate random colors in various formats.
  """
  @moduledoc since: "0.8.0"

  import NeoFaker.Color.Util

  
  
  @doc """
  Generates a random CMYK color as a tuple or W3C-formatted string.
  
  By default, returns a tuple `{c, m, y, k}` with each component as an integer percentage. If `format: :w3c` is specified, returns a string in W3C CMYK format (e.g., `"cmyk(0%, 25%, 50%, 100%)"`).
  
  ## Options
  
    - `:format` – Set to `:w3c` to return a W3C-formatted string; otherwise returns a tuple.
  
  ## Examples
  
      iex> NeoFaker.Color.cmyk()
      {0, 25, 50, 100}
  
      iex> NeoFaker.Color.cmyk(format: :w3c)
      "cmyk(0%, 25%, 50%, 100%)"
  """
  def cmyk(opts \\ []) do
    case Keyword.get(opts, :format) do
      :w3c -> format_cmyk_as_w3c(generate_cmyk_tuple())
      _ -> generate_cmyk_tuple()
    end
  end

  
  
  @doc """
  Generates a random HEX color string in various digit formats.
  
  By default, returns a six-digit HEX color string (e.g., "#A1B2C3"). The output format can be customized using the `:format` option to produce three-digit, four-digit, or eight-digit HEX strings.
  
  ## Options
  
    - `:format` - Specifies the HEX digit format. Accepts `:three_digit`, `:four_digit`, `:eight_digit`, or `nil` (default is six-digit).
  
  ## Examples
  
      iex> NeoFaker.Color.hex()
      "#613583"
  
      iex> NeoFaker.Color.hex(format: :three_digit)
      "#365"
  """
  def hex(opts \\ []) do
    digits =
      case Keyword.get(opts, :format) do
        :three_digit -> 3
        :four_digit -> 4
        :eight_digit -> 8
        _ -> 6
      end

    "#" <> generate_hex_color(digits)
  end

  
  
  @doc """
  Generates a random HSL color as a tuple or W3C-formatted string.
  
  By default, returns an `{hue, saturation, lightness}` tuple. If `format: :w3c` is specified in the options, returns a string in W3C HSL format (e.g., `"hsl(120, 100%, 50%)"`).
  """
  def hsl(opts \\ []) do
    case Keyword.get(opts, :format) do
      :w3c -> format_hsl_as_w3c(generate_hsl_tuple())
      _ -> generate_hsl_tuple()
    end
  end

  
  
  @doc """
  Generates a random HSLA color as a tuple or W3C-formatted string.
  
  By default, returns an `{hue, saturation, lightness, alpha}` tuple. If `format: :w3c` is specified in the options, returns a string in W3C HSLA format (e.g., `"hsla(120, 100%, 50%, 0.5)"`).
  """
  def hsla(opts \\ []) do
    case Keyword.get(opts, :format) do
      :w3c -> format_hsla_as_w3c(generate_hsla_tuple())
      _ -> generate_hsla_tuple()
    end
  end

  
  
  @doc """
  Generates a random keyword color name as a string.
  
  By default, returns a color name from all available keyword color categories. The `:category` option can be used to restrict the selection to `:basic` or `:extended` keyword colors. The `:locale` option specifies the locale for the color name, defaulting to `:default` if not provided.
  
  ## Examples
  
      iex> NeoFaker.Color.keyword()
      "blueviolet"
  
      iex> NeoFaker.Color.keyword(category: :basic)
      "purple"
  
      iex> NeoFaker.Color.keyword(locale: :id_id)
      "ungu"
  """
  def keyword(opts \\ []) do
    generate_keyword_color(
      Keyword.get(opts, :category),
      Keyword.get(opts, :locale, :default)
    )
  end

  
  
  @doc """
  Generates a random RGB color as a tuple or W3C-formatted string.
  
  By default, returns an `{r, g, b}` tuple. If `format: :w3c` is specified in the options, returns a string in W3C RGB format (e.g., `"rgb(123, 45, 67)"`).
  """
  def rgb(opts \\ []) do
    case Keyword.get(opts, :format) do
      :w3c -> format_rgb_as_w3c(generate_rgb_tuple())
      _ -> generate_rgb_tuple()
    end
  end

  
  
  @doc """
  Generates a random RGBA color as a tuple or W3C-formatted string.
  
  By default, returns a tuple `{r, g, b, a}` with integer RGB values and a float alpha value. If `format: :w3c` is specified in the options, returns a W3C-formatted RGBA string.
  """
  def rgba(opts \\ []) do
    case Keyword.get(opts, :format) do
      :w3c -> format_rgba_as_w3c(generate_rgba_tuple())
      _ -> generate_rgba_tuple()
    end
  end
end
