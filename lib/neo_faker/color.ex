defmodule NeoFaker.Color do
  @moduledoc """
  Functions for generating random colors.

  This module provides utilities to generate random colors in various formats including
  CMYK, HEX, HSL, HSLA, RGB, RGBA, and keyword colors with support for W3C formatting.
  """
  @moduledoc since: "0.8.0"

  alias NeoFaker.Color.CMYK
  alias NeoFaker.Color.HEX
  alias NeoFaker.Color.HSL
  alias NeoFaker.Color.HSLA
  alias NeoFaker.Color.Keyword, as: KeywordColor
  alias NeoFaker.Color.RGB
  alias NeoFaker.Color.RGBA
  alias NeoFaker.Helpers.Constants
  alias NeoFaker.Helpers.Options

  @doc """
  Generates a CMYK color.

  Returns a CMYK color as a tuple of four integers representing the cyan, magenta, yellow, and
  black components. Each component is a percentage value from 0 to 100.

  ## Parameters

  - `opts` - Keyword list of options:
    - `:format` - Specifies the output format. Defaults to tuple format.

  ## Options

  The values for `:format` can be:

  - `nil` - Returns the color in tuple format (default).
  - `:w3c` - Returns the color in W3C format.

  ## Examples

      iex> NeoFaker.Color.cmyk()
      {0, 25, 50, 100}

      iex> NeoFaker.Color.cmyk(format: :w3c)
      "cmyk(0%, 25%, 50%, 100%)"

      iex> NeoFaker.Color.cmyk(format: nil)
      {15, 30, 45, 60}

  ## Errors

  Raises `ArgumentError` if an invalid format is provided.

      iex> NeoFaker.Color.cmyk(format: :invalid)
      ** (ArgumentError) Invalid value for :format. Expected one of [nil, :w3c], got: :invalid

  """
  @spec cmyk(Keyword.t()) :: tuple() | String.t()
  def cmyk(opts \\ []) do
    color_tuple = CMYK.color_tuple()

    case get_and_validate_color_format!(opts) do
      :w3c -> CMYK.color_w3c(color_tuple)
      _ -> color_tuple
    end
  end

  @doc """
  Generates a HEX color.

  Returns a HEX color. If no options are provided, the color is returned in six-digit format
  with a leading hash symbol (#).

  ## Parameters

  - `opts` - Keyword list of options:
    - `:format` - Specifies the output format. Defaults to `:six_digit`.

  ## Options

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

      iex> NeoFaker.Color.hex(format: :four_digit)
      "#365F"

      iex> NeoFaker.Color.hex(format: :eight_digit)
      "#613583FF"

  ## Errors

  Raises `ArgumentError` if an invalid format is provided.

      iex> NeoFaker.Color.hex(format: :invalid)
      ** (ArgumentError) Invalid value for :format. Expected one of [:three_digit, :four_digit, :six_digit, :eight_digit], got: :invalid

  """
  @spec hex(Keyword.t()) :: String.t()
  def hex(opts \\ []) do
    format = Options.get(opts, :format, :six_digit)

    validate_hex_format!(format)

    digits =
      case format do
        :three_digit -> 3
        :four_digit -> 4
        :six_digit -> 6
        :eight_digit -> 8
      end

    "#" <> HEX.color(digits)
  end

  @doc """
  Generates an HSL color.

  Returns an HSL (Hue, Saturation, Lightness) color as a tuple or W3C formatted string.
  Hue is in degrees (0-360), while Saturation and Lightness are percentages (0-100).

  ## Parameters

  - `opts` - Keyword list of options:
    - `:format` - Specifies the output format. Defaults to tuple format.

  ## Options

  The values for `:format` can be:

  - `nil` - Returns the color in tuple format (default).
  - `:w3c` - Returns the color in W3C format.

  ## Examples

      iex> NeoFaker.Color.hsl()
      {180, 50, 75}

      iex> NeoFaker.Color.hsl(format: :w3c)
      "hsl(180, 50%, 75%)"

      iex> NeoFaker.Color.hsl(format: nil)
      {240, 100, 50}

  """
  @spec hsl(Keyword.t()) :: tuple() | String.t()
  def hsl(opts \\ []) do
    color_tuple = HSL.color_tuple()

    case get_and_validate_color_format!(opts) do
      :w3c -> HSL.color_w3c(color_tuple)
      _ -> color_tuple
    end
  end

  @doc """
  Generates an HSLA color.

  Returns an HSLA (Hue, Saturation, Lightness, Alpha) color as a tuple or W3C formatted string.
  Hue is in degrees (0-360), Saturation and Lightness are percentages (0-100), and Alpha
  is a value between 0.0 and 1.0.

  ## Parameters

  - `opts` - Keyword list of options:
    - `:format` - Specifies the output format. Defaults to tuple format.

  ## Options

  The values for `:format` can be:

  - `nil` - Returns the color in tuple format (default).
  - `:w3c` - Returns the color in W3C format.

  ## Examples

      iex> NeoFaker.Color.hsla()
      {180, 50, 75, 0.8}

      iex> NeoFaker.Color.hsla(format: :w3c)
      "hsla(180, 50%, 75%, 0.8)"

      iex> NeoFaker.Color.hsla(format: nil)
      {240, 100, 50, 1.0}

  """
  @spec hsla(Keyword.t()) :: tuple() | String.t()
  def hsla(opts \\ []) do
    color_tuple = HSLA.color_tuple()

    case get_and_validate_color_format!(opts) do
      :w3c -> HSLA.color_w3c(color_tuple)
      _ -> color_tuple
    end
  end

  @doc """
  Generates a keyword color.

  Returns a keyword color name. If no options are provided, colors from all categories
  are returned.

  ## Parameters

  - `opts` - Keyword list of options:
    - `:category` - Specifies the category of keyword colors. Defaults to `:all`.
    - `:locale` - Specifies the locale to use. Defaults to the application's current locale.

  ## Options

  The values for `:category` can be:

  - `:all` - Returns all keyword colors (default).
  - `:basic` - Returns basic keyword colors (e.g., "red", "blue", "green").
  - `:extended` - Returns extended keyword colors (e.g., "blueviolet", "cornflowerblue").

  The values for `:locale` can be:

  - `nil` - Uses the default locale `:default`.
  - `:id_id` - Uses the Indonesian locale (returns Indonesian color names).
  - `:en_us` - Uses the US English locale.

  ## Examples

      iex> NeoFaker.Color.keyword()
      "blueviolet"

      iex> NeoFaker.Color.keyword(category: :basic)
      "purple"

      iex> NeoFaker.Color.keyword(locale: :id_id)
      "ungu"

      iex> NeoFaker.Color.keyword(category: :extended, locale: :en_us)
      "cornflowerblue"

  """
  @spec keyword(Keyword.t()) :: String.t()
  def keyword(opts \\ []) do
    category = Options.get(opts, :category, :all)
    locale = Options.get(opts, :locale, Constants.default_locale())

    validate_color_category!(category)

    KeywordColor.color(category, locale)
  end

  @doc """
  Generates an RGB color.

  Returns an RGB (Red, Green, Blue) color as a tuple or W3C formatted string.
  Each component is an integer value from 0 to 255.

  ## Parameters

  - `opts` - Keyword list of options:
    - `:format` - Specifies the output format. Defaults to tuple format.

  ## Options

  The values for `:format` can be:

  - `nil` - Returns the color in tuple format (default).
  - `:w3c` - Returns the color in W3C format.

  ## Examples

      iex> NeoFaker.Color.rgb()
      {255, 128, 64}

      iex> NeoFaker.Color.rgb(format: :w3c)
      "rgb(255, 128, 64)"

      iex> NeoFaker.Color.rgb(format: nil)
      {100, 200, 50}

  ## Errors

  Raises `ArgumentError` if an invalid format is provided.

      iex> NeoFaker.Color.rgb(format: :invalid)
      ** (ArgumentError) Invalid value for :format. Expected one of [nil, :w3c], got: :invalid

  """
  @spec rgb(Keyword.t()) :: tuple() | String.t()
  def rgb(opts \\ []) do
    color_tuple = RGB.color_tuple()

    case get_and_validate_color_format!(opts) do
      :w3c -> RGB.color_w3c(color_tuple)
      _ -> color_tuple
    end
  end

  @doc """
  Generates an RGBA color.

  Returns an RGBA (Red, Green, Blue, Alpha) color as a tuple or W3C formatted string.
  RGB components are integers from 0 to 255, and Alpha is a float between 0.0 and 1.0.

  ## Parameters

  - `opts` - Keyword list of options:
    - `:format` - Specifies the output format. Defaults to tuple format.

  ## Options

  The values for `:format` can be:

  - `nil` - Returns the color in tuple format (default).
  - `:w3c` - Returns the color in W3C format.

  ## Examples

      iex> NeoFaker.Color.rgba()
      {255, 128, 64, 0.8}

      iex> NeoFaker.Color.rgba(format: :w3c)
      "rgba(255, 128, 64, 0.8)"

      iex> NeoFaker.Color.rgba(format: nil)
      {100, 200, 50, 1.0}

  """
  @spec rgba(Keyword.t()) :: tuple() | String.t()
  def rgba(opts \\ []) do
    color_tuple = RGBA.color_tuple()

    case get_and_validate_color_format!(opts) do
      :w3c -> RGBA.color_w3c(color_tuple)
      _ -> color_tuple
    end
  end

  @doc """
  Generates a random color in any format.

  Returns a color in a randomly selected format (CMYK, HEX, HSL, HSLA, RGB, or RGBA).

  ## Parameters

  - `opts` - Keyword list of options:
    - `:format` - If provided, uses that specific format instead of random.

  ## Examples

      iex> NeoFaker.Color.random()
      {255, 128, 64}

      iex> NeoFaker.Color.random()
      "#613583"

      iex> NeoFaker.Color.random()
      {180, 50, 75}

  """
  @spec random(Keyword.t()) :: tuple() | String.t()
  def random(opts \\ []) do
    format_specified = Keyword.has_key?(opts, :format)

    if format_specified do
      # User specified a format, use it
      case Options.get(opts, :format, nil) do
        :w3c -> Enum.random([cmyk(opts), hsl(opts), hsla(opts), rgb(opts), rgba(opts)])
        _ -> Enum.random([cmyk(opts), hex(opts), hsl(opts), hsla(opts), rgb(opts), rgba(opts)])
      end
    else
      # Random format selection
      Enum.random([
        cmyk(),
        hex(),
        hsl(),
        hsla(),
        rgb(),
        rgba()
      ])
    end
  end

  # Private functions

  @spec get_and_validate_color_format!(Keyword.t()) :: atom() | nil
  defp get_and_validate_color_format!(opts) do
    format = Options.get(opts, :format, nil)
    valid_formats = Constants.valid_color_formats()

    case Options.validate_enum(:format, format, valid_formats) do
      :ok ->
        format

      {:error, reason} ->
        raise ArgumentError, reason
    end
  end

  @spec validate_hex_format!(atom()) :: :ok
  defp validate_hex_format!(format) do
    valid_formats = Constants.valid_hex_formats()

    case Options.validate_enum(:format, format, valid_formats) do
      :ok ->
        :ok

      {:error, reason} ->
        raise ArgumentError, reason
    end
  end

  @spec validate_color_category!(atom()) :: :ok
  defp validate_color_category!(category) do
    valid_categories = Constants.valid_color_keyword_categories()

    case Options.validate_enum(:category, category, valid_categories) do
      :ok ->
        :ok

      {:error, reason} ->
        raise ArgumentError, reason
    end
  end
end
