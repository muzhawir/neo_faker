defmodule NeoFaker.Color do
  @moduledoc """
  Functions for generating random colors.

  This module provides utilities to generate random colors in various formats.
  """
  @moduledoc since: "0.8.0"

  import NeoFaker.Color.Util

  @doc """
  Generates a CMYK color.

  Returns a CMYK color as a tuple of four integers representing the cyan, magenta, yellow, and
  black components.

  ## Options

  - `:format` - Specifies the output format.

  The values for `:format` can be:

  - `nil` - Returns the color in tuple format (default).
  - `:w3c` - Returns the color in W3C format.

  ## Examples

      iex> NeoFaker.Color.cmyk()
      {0, 25, 50, 100}

      iex> NeoFaker.Color.cmyk(format: :w3c)
      "cmyk(0%, 25%, 50%, 100%)"

  """
  @spec cmyk(Keyword.t()) :: tuple() | String.t()
  def cmyk(opts \\ []) do
    case Keyword.get(opts, :format) do
      :w3c -> format_cmyk_as_w3c(generate_cmyk_tuple())
      _ -> generate_cmyk_tuple()
    end
  end

  @doc """
  Generates a HEX color.

  Returns a HEX color. If no options are provided, the color is returned in six-digit format.

  ## Options

  - `:format` - Specifies the output format.

  The values for `:format` can be:

  - `:six_digit` - Returns the color in six-digit format (default).
  - `:three_digit` - Returns the color in three-digit format.
  - `:four_digit` - Returns the color in four-digit format.
  - `:eight_digit` - Returns the color in eight-digit format.

  ## Examples

      iex> NeoFaker.Color.hex()
      "#613583"

      iex> NeoFaker.Color.hex(format: :three_digit)
      "#365"

  """
  @spec hex(Keyword.t()) :: String.t()
  def hex(opts \\ []) do
    digits =
      case Keyword.get(opts, :format) do
        :three_digit -> 3
        :four_digit -> 4
        :six_digit -> 6
        :eight_digit -> 8
        _ -> 6
      end

    "#" <> generate_hex_color(digits)
  end

  @doc """
  Generates an HSL color.

  This function behaves the same way as `cmyk/1`, but it generates an HSL color instead.
  """
  @spec hsl(Keyword.t()) :: tuple() | String.t()
  def hsl(opts \\ []) do
    case Keyword.get(opts, :format) do
      :w3c -> format_hsl_as_w3c(generate_hsl_tuple())
      _ -> generate_hsl_tuple()
    end
  end

  @doc """
  Generates an HSLA color.

  This function behaves the same way as `cmyk/1`. See `cmyk/1` for more details.
  """
  @spec hsla(Keyword.t()) :: tuple() | String.t()
  def hsla(opts \\ []) do
    case Keyword.get(opts, :format) do
      :w3c -> format_hsla_as_w3c(generate_hsla_tuple())
      _ -> generate_hsla_tuple()
    end
  end

  @doc """
  Generates a keyword color.

  Returns a keyword color. If no options are provided, all category colors are returned.

  ## Options

  - `:category` - Specifies the category of keyword colors.
  - `:locale` - Specifies the locale to use.

  The values for `:category` can be:

  - `:all` - Returns all keyword colors (default).
  - `:basic` - Returns basic keyword colors.
  - `:extended` - Returns extended keyword colors.

  The values for `:locale` can be:

  - `nil` - Uses the default locale `:default`.
  - `:id_id` - Uses the Indonesian locale, for example.

  ## Examples

      iex> NeoFaker.Color.keyword()
      "blueviolet"

      iex> NeoFaker.Color.keyword(category: :basic)
      "purple"

      iex> NeoFaker.Color.keyword(locale: :id_id)
      "ungu"

  """
  @spec keyword(Keyword.t()) :: String.t()
  def keyword(opts \\ []) do
    generate_keyword_color(
      Keyword.get(opts, :category, :all),
      Keyword.get(opts, :locale, :default)
    )
  end

  @doc """
  Generates an RGB color.

  This function behaves the same way as `cmyk/1`, but it generates an RGB color instead.
  """
  @spec rgb(Keyword.t()) :: tuple() | String.t()
  def rgb(opts \\ []) do
    case Keyword.get(opts, :format) do
      :w3c -> format_rgb_as_w3c(generate_rgb_tuple())
      _ -> generate_rgb_tuple()
    end
  end

  @doc """
  Generates an RGBA color.

  This function behaves the same way as `cmyk/1`, but it generates an RGBA color instead.
  """
  @spec rgba(Keyword.t()) :: tuple() | String.t()
  def rgba(opts \\ []) do
    case Keyword.get(opts, :format) do
      :w3c -> format_rgba_as_w3c(generate_rgba_tuple())
      _ -> generate_rgba_tuple()
    end
  end
end
