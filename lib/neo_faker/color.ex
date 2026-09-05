defmodule NeoFaker.Color do
  @moduledoc """
  Functions for generating random colors.

  Provides utilities to generate random colors in various formats including
  CMYK, HEX, HSL, HSLA, RGB, RGBA, and CSS keyword colors, with optional
  W3C string formatting.
  """
  @moduledoc since: "0.8.0"

  alias NeoFaker.Color.CMYK
  alias NeoFaker.Color.HEX
  alias NeoFaker.Color.HSL
  alias NeoFaker.Color.HSLA
  alias NeoFaker.Color.Keyword, as: KeywordColor
  alias NeoFaker.Color.RGB
  alias NeoFaker.Color.RGBA
  alias NeoFaker.Color.Validator
  alias NeoFaker.Helpers.Options

  @doc """
  Generates a random CMYK color.

  Returns a tuple `{cyan, magenta, yellow, black}` where each component is an
  integer percentage from 0 to 100. Pass `format: :w3c` for a CSS string.

  ## Options

  - `:format` - Output format. Either `nil` (tuple, default) or `:w3c` (CSS string).

  ## Examples

      iex> NeoFaker.Color.cmyk()
      {0, 25, 50, 100}

      iex> NeoFaker.Color.cmyk(format: :w3c)
      "cmyk(0%, 25%, 50%, 100%)"

  """
  @spec cmyk(Keyword.t()) :: tuple() | String.t()
  def cmyk(opts \\ []) do
    color_tuple = CMYK.color_tuple()

    case Validator.get_and_validate_color_format!(opts) do
      :w3c -> CMYK.color_w3c(color_tuple)
      nil -> color_tuple
    end
  end

  @doc """
  Generates a random HEX color string.

  Returns a `#`-prefixed hex color. Defaults to six-digit format.

  ## Options

  - `:format` - Digit length. One of `:six_digit` (default), `:three_digit`,
    `:four_digit`, or `:eight_digit`.

  ## Examples

      iex> NeoFaker.Color.hex()
      "#613583"

      iex> NeoFaker.Color.hex(format: :three_digit)
      "#365"

      iex> NeoFaker.Color.hex(format: :eight_digit)
      "#613583FF"

  """
  @spec hex(Keyword.t()) :: String.t()
  def hex(opts \\ []) do
    format = Options.get(opts, :format, :six_digit)

    Validator.validate_hex_format!(format)

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
  Generates a random HSL color.

  Returns a `{hue, saturation, lightness}` tuple. Hue is in degrees (0–360);
  saturation and lightness are integer percentages (0–100). Pass `format: :w3c`
  for a CSS string.

  ## Options

  - `:format` - Output format. Either `nil` (tuple, default) or `:w3c` (CSS string).

  ## Examples

      iex> NeoFaker.Color.hsl()
      {180, 50, 75}

      iex> NeoFaker.Color.hsl(format: :w3c)
      "hsl(180, 50%, 75%)"

  """
  @spec hsl(Keyword.t()) :: tuple() | String.t()
  def hsl(opts \\ []) do
    color_tuple = HSL.color_tuple()

    case Validator.get_and_validate_color_format!(opts) do
      :w3c -> HSL.color_w3c(color_tuple)
      nil -> color_tuple
    end
  end

  @doc """
  Generates a random HSLA color.

  Returns a `{hue, saturation, lightness, alpha}` tuple. Hue is in degrees (0–360),
  saturation and lightness are integer percentages (0–100), and alpha is a float
  between 0.0 and 1.0. Pass `format: :w3c` for a CSS string.

  ## Options

  - `:format` - Output format. Either `nil` (tuple, default) or `:w3c` (CSS string).

  ## Examples

      iex> NeoFaker.Color.hsla()
      {180, 50, 75, 0.8}

      iex> NeoFaker.Color.hsla(format: :w3c)
      "hsla(180, 50%, 75%, 0.8)"

  """
  @spec hsla(Keyword.t()) :: tuple() | String.t()
  def hsla(opts \\ []) do
    color_tuple = HSLA.color_tuple()

    case Validator.get_and_validate_color_format!(opts) do
      :w3c -> HSLA.color_w3c(color_tuple)
      nil -> color_tuple
    end
  end

  @doc """
  Generates a random CSS keyword color name.

  Returns a color name string such as `"blueviolet"` or `"purple"`. Supports
  locale-specific color names (e.g. Indonesian via `locale: :id_id`).

  ## Options

  - `:category` - Color category. One of `:all` (default), `:basic`, or `:extended`.
  - `:locale` - Locale to use. Defaults to the application's configured locale.

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
    category = Options.get(opts, :category, :all)
    locale = Options.get(opts, :locale, :default)

    Validator.validate_color_category!(category)

    KeywordColor.color(category, locale)
  end

  @doc """
  Generates a random RGB color.

  Returns a `{red, green, blue}` tuple where each component is an integer from
  0 to 255. Pass `format: :w3c` for a CSS string.

  ## Options

  - `:format` - Output format. Either `nil` (tuple, default) or `:w3c` (CSS string).

  ## Examples

      iex> NeoFaker.Color.rgb()
      {255, 128, 64}

      iex> NeoFaker.Color.rgb(format: :w3c)
      "rgb(255, 128, 64)"

  """
  @spec rgb(Keyword.t()) :: tuple() | String.t()
  def rgb(opts \\ []) do
    color_tuple = RGB.color_tuple()

    case Validator.get_and_validate_color_format!(opts) do
      :w3c -> RGB.color_w3c(color_tuple)
      nil -> color_tuple
    end
  end

  @doc """
  Generates a random RGBA color.

  Returns a `{red, green, blue, alpha}` tuple. RGB components are integers from
  0 to 255; alpha is a float between 0.0 and 1.0. Pass `format: :w3c` for a
  CSS string.

  ## Options

  - `:format` - Output format. Either `nil` (tuple, default) or `:w3c` (CSS string).

  ## Examples

      iex> NeoFaker.Color.rgba()
      {255, 128, 64, 0.8}

      iex> NeoFaker.Color.rgba(format: :w3c)
      "rgba(255, 128, 64, 0.8)"

  """
  @spec rgba(Keyword.t()) :: tuple() | String.t()
  def rgba(opts \\ []) do
    color_tuple = RGBA.color_tuple()

    case Validator.get_and_validate_color_format!(opts) do
      :w3c -> RGBA.color_w3c(color_tuple)
      nil -> color_tuple
    end
  end

  @doc """
  Generates a random color in a randomly selected format.

  With no options, picks uniformly among CMYK, HEX, HSL, HSLA, RGB, and RGBA.
  Pass `format: :w3c` to restrict the pool to formats that support W3C strings
  (excludes HEX), or any other `:format` value to pass it through to each
  individual generator.

  ## Examples

      iex> NeoFaker.Color.random()
      {255, 128, 64}

      iex> NeoFaker.Color.random()
      "#613583"

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
      Enum.random([cmyk(), hex(), hsl(), hsla(), rgb(), rgba()])
    end
  end
end
