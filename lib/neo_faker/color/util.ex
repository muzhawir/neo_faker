defmodule NeoFaker.Color.Util do
  @moduledoc false

  import NeoFaker.Data.Cache, only: [fetch_cache!: 3]
  import NeoFaker.Data.Generator, only: [random_data: 4]
  import NeoFaker.Number, only: [between: 0, between: 2]

  @module NeoFaker.Color
  @hex_digits Enum.shuffle(~w[0 1 2 3 4 5 6 7 8 9 A B C D E F])

  @doc """
  Generates a CMYK color.

  This function delegates the call to `NeoFaker.Color.cmyk/1`.
  """
  @spec cmyk(Keyword.t()) :: tuple() | String.t()
  def cmyk(opts \\ []) do
    case Keyword.get(opts, :format) do
      :w3c -> format_cmyk_as_w3c(generate_cmyk_tuple())
      _ -> generate_cmyk_tuple()
    end
  end

  defp generate_cmyk_tuple, do: {between(), between(), between(), between()}

  defp format_cmyk_as_w3c({c, m, y, k}), do: "cmyk(#{c}%, #{m}%, #{y}%, #{k}%)"

  @doc """
  Generates a HEX color.

  This function delegates the call to `NeoFaker.Color.hex/1`.
  """
  @spec hex(Keyword.t()) :: String.t()
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

  defp generate_hex_color(digits) do
    Enum.map_join(1..digits, "", fn _ -> Enum.random(@hex_digits) end)
  end

  @doc """
  Generates an HSL color.

  This function delegates the call to `NeoFaker.Color.hsl/1`.
  """
  @spec hsl(Keyword.t()) :: tuple() | String.t()
  def hsl(opts \\ []) do
    case Keyword.get(opts, :format) do
      :w3c -> format_hsl_as_w3c(generate_hsl_tuple())
      _ -> generate_hsl_tuple()
    end
  end

  defp generate_hsl_tuple, do: {between(0, 359), between(), between()}

  defp format_hsl_as_w3c({h, s, l}), do: "hsl(#{h}, #{s}%, #{l}%)"

  @doc """
  Generates an HSLA color.

  This function delegates the call to `NeoFaker.Color.hsla/1`.
  """
  @spec hsla(Keyword.t()) :: tuple() | String.t()
  def hsla(opts \\ []) do
    case Keyword.get(opts, :format) do
      :w3c -> format_hsla_as_w3c(generate_hsla_tuple())
      _ -> generate_hsla_tuple()
    end
  end

  defp generate_hsla_tuple do
    alpha = Float.round(between(0.0, 1.0), 1)

    {between(0, 359), between(), between(), alpha}
  end

  defp format_hsla_as_w3c({h, s, l, a}) do
    "hsla(#{h}, #{s}%, #{l}%, #{a})"
  end

  @doc """
  Generates a keyword color.

  This function delegates the call to `NeoFaker.Color.keyword/1`.
  """
  @spec keyword(Keyword.t()) :: String.t()
  def keyword(opts \\ []) do
    generate_keyword_color(
      Keyword.get(opts, :category),
      Keyword.get(opts, :locale, :default)
    )
  end

  defp generate_keyword_color(nil, locale) do
    locale
    |> fetch_cache!(@module, "keyword.exs")
    |> Map.values()
    |> List.flatten()
    |> Enum.random()
  end

  defp generate_keyword_color(category, locale) do
    random_data(@module, "keyword.exs", Atom.to_string(category), locale: locale)
  end

  @doc """
  Generates an RGB color.

  This function delegates the call to `NeoFaker.Color.rgb/1`.
  """
  @spec rgb(Keyword.t()) :: tuple() | String.t()
  def rgb(opts \\ []) do
    case Keyword.get(opts, :format) do
      :w3c -> format_rgb_as_w3c(generate_rgb_tuple())
      _ -> generate_rgb_tuple()
    end
  end

  defp generate_rgb_tuple, do: {between(0, 255), between(0, 255), between(0, 255)}

  defp format_rgb_as_w3c({r, g, b}), do: "rgb(#{r}, #{g}, #{b})"

  @doc """
  Generates an RGBA color.

  This function delegates the call to `NeoFaker.Color.rgba/1`.
  """
  @spec rgba(Keyword.t()) :: tuple() | String.t()
  def rgba(opts \\ []) do
    case Keyword.get(opts, :format) do
      :w3c -> format_rgba_as_w3c(generate_rgba_tuple())
      _ -> generate_rgba_tuple()
    end
  end

  defp generate_rgba_tuple do
    alpha = Float.round(between(0.0, 1.0), 1)

    {between(0, 255), between(0, 255), between(0, 255), alpha}
  end

  defp format_rgba_as_w3c({r, g, b, a}), do: "rgba(#{r}, #{g}, #{b}, #{a})"
end
