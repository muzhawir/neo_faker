defmodule NeoFaker.Color.Util do
  @moduledoc false

  import NeoFaker.Data.Cache, only: [fetch_cache!: 3]
  import NeoFaker.Data.Generator, only: [random_data: 4]
  import NeoFaker.Number, only: [between: 0, between: 2]

  @module NeoFaker.Color
  @hex_digits Enum.shuffle(~w[0 1 2 3 4 5 6 7 8 9 A B C D E F])

  
  
  @doc """
Generates a tuple representing a random CMYK color, with each component (cyan, magenta, yellow, black) as a number between 0 and 100.
"""
def generate_cmyk_tuple, do: {between(), between(), between(), between()}

  
  
  @doc """
Formats a CMYK color tuple as a W3C-compliant string in the form "cmyk(c%, m%, y%, k%)".

## Examples

    iex> format_cmyk_as_w3c({10, 20, 30, 40})
    "cmyk(10%, 20%, 30%, 40%)"
"""
def format_cmyk_as_w3c({c, m, y, k}), do: "cmyk(#{c}%, #{m}%, #{y}%, #{k}%)"

  
  
  @doc """
  Generates a random HEX color string of the specified length.
  
  The resulting string consists of randomly selected hexadecimal digits (0-9, a-f).
  """
  def generate_hex_color(digits) do
    Enum.map_join(1..digits, "", fn _ -> Enum.random(@hex_digits) end)
  end

  
  
  @doc """
Generates a random HSL color tuple with hue between 0 and 359, and saturation and lightness between 0 and 100.
"""
def generate_hsl_tuple, do: {between(0, 359), between(), between()}

  
  
  @doc """
Formats an HSL color tuple as a W3C-compliant string in the form "hsl(h, s%, l%)".
"""
def format_hsl_as_w3c({h, s, l}), do: "hsl(#{h}, #{s}%, #{l}%)"

  
  
  @doc """
  Generates a random HSLA color tuple with hue (0–359), saturation and lightness (0–100), and alpha (0.0–1.0) rounded to one decimal place.
  """
  def generate_hsla_tuple do
    alpha = Float.round(between(0.0, 1.0), 1)

    {between(0, 359), between(), between(), alpha}
  end

  
  
  @doc """
Formats an HSLA color tuple as a W3C-compliant string in the form "hsla(h, s%, l%, a)".
"""
def format_hsla_as_w3c({h, s, l, a}), do: "hsla(#{h}, #{s}%, #{l}%, #{a})"

  
  
  @doc """
  Returns a random keyword color string for the specified locale and optional category.
  
  If `category` is `nil`, selects a random color from all available keyword colors for the given locale.
  """
  def generate_keyword_color(nil, locale) do
    locale
    |> fetch_cache!(@module, "keyword.exs")
    |> Map.values()
    |> List.flatten()
    |> Enum.random()
  end

  @doc """
  Returns a random keyword color string from the specified category and locale.
  
  If `category` is `nil`, selects a random color from all available keyword colors for the given locale.
  """
  def generate_keyword_color(category, locale) do
    random_data(@module, "keyword.exs", Atom.to_string(category), locale: locale)
  end

  
  
  @doc """
Generates a tuple representing an RGB color with each component randomly selected between 0 and 255.
"""
def generate_rgb_tuple, do: {between(0, 255), between(0, 255), between(0, 255)}

  
  
  @doc """
Formats an RGB color tuple as a W3C-compliant string in the form "rgb(r, g, b)".
"""
def format_rgb_as_w3c({r, g, b}), do: "rgb(#{r}, #{g}, #{b})"

  
  
  @doc """
  Generates a random RGBA color tuple with red, green, and blue components between 0 and 255, and an alpha value between 0.0 and 1.0 rounded to one decimal place.
  """
  def generate_rgba_tuple do
    alpha = Float.round(between(0.0, 1.0), 1)

    {between(0, 255), between(0, 255), between(0, 255), alpha}
  end

  
  
  @doc """
Formats an RGBA color tuple as a W3C-compliant string in the form "rgba(r, g, b, a)".
"""
def format_rgba_as_w3c({r, g, b, a}), do: "rgba(#{r}, #{g}, #{b}, #{a})"
end
