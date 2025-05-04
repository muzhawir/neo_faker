defmodule NeoFaker.Color.Util do
  @moduledoc false

  import NeoFaker.Data.Cache, only: [fetch_cache!: 3]
  import NeoFaker.Data.Generator, only: [random_data: 4]
  import NeoFaker.Number, only: [between: 0, between: 2]

  @module NeoFaker.Color
  @hex_digits Enum.shuffle(~w[0 1 2 3 4 5 6 7 8 9 A B C D E F])

  @doc """
  Generates a CMYK color in tuple format.
  """
  @spec generate_cmyk_tuple() :: {number(), number(), number(), number()}
  def generate_cmyk_tuple, do: {between(), between(), between(), between()}

  @doc """
  Generates a CMYK color as a W3C string format.
  """
  @spec format_cmyk_as_w3c({number(), number(), number(), number()}) :: String.t()
  def format_cmyk_as_w3c({c, m, y, k}), do: "cmyk(#{c}%, #{m}%, #{y}%, #{k}%)"

  @doc """
  Generates a HEX color in string format.
  """
  @spec generate_hex_color(number()) :: String.t()
  def generate_hex_color(digits) do
    Enum.map_join(1..digits, "", fn _ -> Enum.random(@hex_digits) end)
  end

  @doc """
  Generates a HSL color in tuple format.
  """
  @spec generate_hsl_tuple() :: {number(), number(), number()}
  def generate_hsl_tuple, do: {between(0, 359), between(), between()}

  @doc """
  Generates a HSL color as a W3C string format.
  """
  @spec format_hsl_as_w3c({number(), number(), number()}) :: String.t()
  def format_hsl_as_w3c({h, s, l}), do: "hsl(#{h}, #{s}%, #{l}%)"

  @doc """
  Generates a HSLA color in tuple format.
  """
  @spec generate_hsla_tuple() :: {number(), number(), number(), number()}
  def generate_hsla_tuple do
    alpha = Float.round(between(0.0, 1.0), 1)

    {between(0, 359), between(), between(), alpha}
  end

  @doc """
  Generates a HSLA color as a W3C string format.
  """
  @spec format_hsla_as_w3c({number(), number(), number(), number()}) :: String.t()
  def format_hsla_as_w3c({h, s, l, a}), do: "hsla(#{h}, #{s}%, #{l}%, #{a})"

  @doc """
  Generates a keyword color based on the given category and locale.

  If no category is provided all keyword colors are returned.
  """
  @spec generate_keyword_color(atom(), atom()) :: String.t()
  def generate_keyword_color(nil, locale) do
    locale
    |> fetch_cache!(@module, "keyword.exs")
    |> Map.values()
    |> List.flatten()
    |> Enum.random()
  end

  def generate_keyword_color(category, locale) do
    random_data(@module, "keyword.exs", Atom.to_string(category), locale: locale)
  end

  @doc """
  Generates an RGB color in tuple format.
  """
  @spec generate_rgb_tuple() :: {number(), number(), number()}
  def generate_rgb_tuple, do: {between(0, 255), between(0, 255), between(0, 255)}

  @doc """
  Generates an RGB color as a W3C string format.
  """
  @spec format_rgb_as_w3c({number(), number(), number()}) :: String.t()
  def format_rgb_as_w3c({r, g, b}), do: "rgb(#{r}, #{g}, #{b})"

  @doc """
  Generates an RGBA color in tuple format.
  """
  @spec generate_rgba_tuple() :: {number(), number(), number(), number()}
  def generate_rgba_tuple do
    alpha = Float.round(between(0.0, 1.0), 1)

    {between(0, 255), between(0, 255), between(0, 255), alpha}
  end

  @doc """
  Generates an RGBA color as a W3C string format.
  """
  @spec format_rgba_as_w3c({number(), number(), number(), number()}) :: String.t()
  def format_rgba_as_w3c({r, g, b, a}), do: "rgba(#{r}, #{g}, #{b}, #{a})"
end
