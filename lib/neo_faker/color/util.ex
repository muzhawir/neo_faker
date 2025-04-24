defmodule NeoFaker.Color.Util do
  @moduledoc false

  import NeoFaker.Data.Cache, only: [fetch_cache!: 3]
  import NeoFaker.Data.Generator, only: [random_data: 4]
  import NeoFaker.Number, only: [between: 0, between: 2]

  @module NeoFaker.Color
  @hex_number Enum.shuffle(~w[0 1 2 3 4 5 6 7 8 9 A B C D E F])

  @doc """
  Generates a CMYK color.

  This function delegates the call to `NeoFaker.Color.cmyk/1`.
  """
  @spec cmyk(Keyword.t()) :: tuple() | String.t()
  def cmyk(opts \\ [])
  def cmyk([]), do: generate_random_cmyk_color()

  def cmyk(format: :w3c) do
    cmyk_value =
      generate_random_cmyk_color()
      |> Tuple.to_list()
      |> Enum.map_join(", ", fn n -> "#{n}%" end)

    "cmyk(#{cmyk_value})"
  end

  defp generate_random_cmyk_color, do: {between(), between(), between(), between()}

  @doc """
  Generates a HEX color.

  This function delegates the call to `NeoFaker.Color.hex/1`.
  """
  @spec hex(Keyword.t()) :: String.t()
  def hex(opts \\ [])
  def hex([]), do: "#" <> generate_random_hex_color(6)
  def hex(format: :three_digit), do: "#" <> generate_random_hex_color(3)
  def hex(format: :four_digit), do: "#" <> generate_random_hex_color(4)
  def hex(format: :eight_digit), do: "#" <> generate_random_hex_color(8)

  defp generate_random_hex_color(digit) do
    Enum.map_join(1..digit, "", fn _ -> Enum.random(@hex_number) end)
  end

  @doc """
  Generates a HSL color.

  This function delegates the call to `NeoFaker.Color.hsl/1`.
  """
  @spec hsl(Keyword.t()) :: tuple() | String.t()
  def hsl(opts \\ [])
  def hsl([]), do: generate_random_hsl_color()

  def hsl(format: :w3c) do
    {h, s, l} = generate_random_hsl_color()

    "hsl(#{h}, #{s}%, #{l}%)"
  end

  defp generate_random_hsl_color, do: {between(0, 359), between(), between()}

  @doc """
  Generates a HSLA color.

  This function delegates the call to `NeoFaker.Color.hsla/1`.
  """
  @spec hsla(Keyword.t()) :: tuple() | String.t()
  def hsla(opts \\ [])
  def hsla([]), do: generate_random_hsla_color()

  def hsla(format: :w3c) do
    {h, s, l, a} = generate_random_hsla_color()

    "hsla(#{h}, #{s}%, #{l}%, #{a})"
  end

  defp generate_random_hsla_color do
    alpha = 0.0 |> between(1.0) |> Float.round(1)

    {between(0, 359), between(), between(), alpha}
  end

  @doc """
  Generates a keyword color.

  This function delegates the call to `NeoFaker.Color.keyword/1`.
  """
  @spec keyword(Keyword.t()) :: String.t()
  def keyword(opts \\ []) do
    category = Keyword.get(opts, :category)
    locale = Keyword.get(opts, :locale, :default)

    keyword_color(category, locale)
  end

  defp keyword_color(nil, locale) do
    locale
    |> fetch_cache!(@module, "keyword.exs")
    |> Map.values()
    |> List.flatten()
    |> Enum.random()
  end

  defp keyword_color(:basic, locale) do
    random_data(@module, "keyword.exs", "basic", locale: locale)
  end

  defp keyword_color(:extended, locale) do
    random_data(@module, "keyword.exs", "extended", locale: locale)
  end

  @doc """
  Generates a RGB color.

  This function delegates the call to `NeoFaker.Color.rgb/1`.
  """
  @spec rgb(Keyword.t()) :: tuple() | String.t()
  def rgb(opts \\ [])
  def rgb([]), do: generate_random_rgb_color()

  def rgb(format: :w3c) do
    {r, g, b} = generate_random_rgb_color()

    "rgb(#{r}, #{g}, #{b})"
  end

  defp generate_random_rgb_color, do: {between(0, 255), between(0, 255), between(0, 255)}

  @doc """
  Generates a RGBA color.

  This function delegates the call to `NeoFaker.Color.rgba/1`.
  """
  @spec rgba(Keyword.t()) :: tuple() | String.t()
  def rgba(opts \\ [])
  def rgba([]), do: generate_random_rgba_color()

  def rgba(format: :w3c) do
    {r, g, b, a} = generate_random_rgba_color()

    "rgba(#{r}, #{g}, #{b}, #{a})"
  end

  defp generate_random_rgba_color do
    alpha = 0.0 |> between(1.0) |> Float.round(1)

    {between(0, 255), between(0, 255), between(0, 255), alpha}
  end
end
