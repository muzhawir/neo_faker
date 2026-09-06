defmodule NeoFaker.Color do
  @moduledoc """
  Functions for generating random colors.

  Provides utilities to generate random colors in various formats including
  CMYK, HEX, HSL, HSLA, RGB, RGBA, and CSS keyword colors, with optional
  W3C string formatting.
  """
  @moduledoc since: "0.8.0"

  alias NeoFaker.Color.CmykGenerator
  alias NeoFaker.Color.HexGenerator
  alias NeoFaker.Color.HslaGenerator
  alias NeoFaker.Color.HslGenerator
  alias NeoFaker.Color.KeywordGenerator
  alias NeoFaker.Color.RgbaGenerator
  alias NeoFaker.Color.RgbGenerator
  alias NeoFaker.Helpers.Options

  @w3c_format_schema NimbleOptions.new!(format: [type: {:in, [nil, :w3c]}, default: nil])

  @hex_schema NimbleOptions.new!(
                format: [
                  type: {:in, [:three_digit, :four_digit, :six_digit, :eight_digit]},
                  default: :six_digit
                ]
              )

  @keyword_schema NimbleOptions.new!(
                    category: [type: {:in, [:all, :basic, :extended]}, default: :all],
                    locale: [type: :atom, default: nil]
                  )

  @typedoc """
  Any value a color-generating function in this module can return: a tuple of numeric
  components, or a W3C-formatted CSS string. Which shape comes back depends on the
  `:format` option (and, for `random/1`, on which format is randomly picked) — this is
  intentional, not an accident of implementation.
  """
  @type any_color :: tuple() | String.t()

  @doc """
  Generates a random CMYK color.

  Returns a tuple `{cyan, magenta, yellow, black}` where each component is an
  integer percentage from 0 to 100.

  ## Options

    * `:format` (`nil` or `:w3c`) - when `:w3c`, returns a CSS `cmyk(...)` string instead
      of a tuple. Defaults to `nil`.

  ## Examples

      iex> NeoFaker.Color.cmyk()
      {0, 25, 50, 100}

      iex> NeoFaker.Color.cmyk(format: :w3c)
      "cmyk(0%, 25%, 50%, 100%)"

  """
  @spec cmyk(keyword()) :: any_color()
  def cmyk(opts \\ []) do
    opts = Options.validate!(opts, @w3c_format_schema)
    color_tuple = CmykGenerator.color_tuple()

    case Keyword.fetch!(opts, :format) do
      :w3c -> CmykGenerator.color_w3c(color_tuple)
      nil -> color_tuple
    end
  end

  @doc """
  Generates a random HEX color string.

  Returns a `#`-prefixed hex color.

  ## Options

    * `:format` (`:three_digit`, `:four_digit`, `:six_digit`, or `:eight_digit`) - the digit
      length of the output. Defaults to `:six_digit`.

  ## Examples

      iex> NeoFaker.Color.hex()
      "#613583"

      iex> NeoFaker.Color.hex(format: :three_digit)
      "#365"

      iex> NeoFaker.Color.hex(format: :eight_digit)
      "#613583FF"

  """
  @spec hex(keyword()) :: String.t()
  def hex(opts \\ []) do
    opts = Options.validate!(opts, @hex_schema)

    digits =
      case Keyword.fetch!(opts, :format) do
        :three_digit -> 3
        :four_digit -> 4
        :six_digit -> 6
        :eight_digit -> 8
      end

    "#" <> HexGenerator.color(digits)
  end

  @doc """
  Generates a random HSL color.

  Returns a `{hue, saturation, lightness}` tuple. Hue is in degrees (0–360);
  saturation and lightness are integer percentages (0–100).

  ## Options

    * `:format` (`nil` or `:w3c`) - when `:w3c`, returns a CSS `hsl(...)` string instead
      of a tuple. Defaults to `nil`.

  ## Examples

      iex> NeoFaker.Color.hsl()
      {180, 50, 75}

      iex> NeoFaker.Color.hsl(format: :w3c)
      "hsl(180, 50%, 75%)"

  """
  @spec hsl(keyword()) :: any_color()
  def hsl(opts \\ []) do
    opts = Options.validate!(opts, @w3c_format_schema)
    color_tuple = HslGenerator.color_tuple()

    case Keyword.fetch!(opts, :format) do
      :w3c -> HslGenerator.color_w3c(color_tuple)
      nil -> color_tuple
    end
  end

  @doc """
  Generates a random HSLA color.

  Returns a `{hue, saturation, lightness, alpha}` tuple. Hue is in degrees (0–360),
  saturation and lightness are integer percentages (0–100), and alpha is a float
  between 0.0 and 1.0.

  ## Options

    * `:format` (`nil` or `:w3c`) - when `:w3c`, returns a CSS `hsla(...)` string instead
      of a tuple. Defaults to `nil`.

  ## Examples

      iex> NeoFaker.Color.hsla()
      {180, 50, 75, 0.8}

      iex> NeoFaker.Color.hsla(format: :w3c)
      "hsla(180, 50%, 75%, 0.8)"

  """
  @spec hsla(keyword()) :: any_color()
  def hsla(opts \\ []) do
    opts = Options.validate!(opts, @w3c_format_schema)
    color_tuple = HslaGenerator.color_tuple()

    case Keyword.fetch!(opts, :format) do
      :w3c -> HslaGenerator.color_w3c(color_tuple)
      nil -> color_tuple
    end
  end

  @doc """
  Generates a random CSS keyword color name.

  Returns a color name string such as `"blueviolet"` or `"purple"`. Supports
  locale-specific color names (e.g. Indonesian via `locale: :id_id`).

  ## Options

    * `:category` (`:all`, `:basic`, or `:extended`) - the color category to draw from.
      Defaults to `:all`.
    * `:locale` (atom) - the locale to use. Defaults to the application's configured
      locale.

  ## Examples

      iex> NeoFaker.Color.keyword()
      "blueviolet"

      iex> NeoFaker.Color.keyword(category: :basic)
      "purple"

      iex> NeoFaker.Color.keyword(locale: :id_id)
      "ungu"

  """
  @spec keyword(keyword()) :: String.t()
  def keyword(opts \\ []) do
    opts = Options.validate!(opts, @keyword_schema)
    KeywordGenerator.color(Keyword.fetch!(opts, :category), Keyword.fetch!(opts, :locale))
  end

  @doc """
  Generates a random RGB color.

  Returns a `{red, green, blue}` tuple where each component is an integer from
  0 to 255.

  ## Options

    * `:format` (`nil` or `:w3c`) - when `:w3c`, returns a CSS `rgb(...)` string instead
      of a tuple. Defaults to `nil`.

  ## Examples

      iex> NeoFaker.Color.rgb()
      {255, 128, 64}

      iex> NeoFaker.Color.rgb(format: :w3c)
      "rgb(255, 128, 64)"

  """
  @spec rgb(keyword()) :: any_color()
  def rgb(opts \\ []) do
    opts = Options.validate!(opts, @w3c_format_schema)
    color_tuple = RgbGenerator.color_tuple()

    case Keyword.fetch!(opts, :format) do
      :w3c -> RgbGenerator.color_w3c(color_tuple)
      nil -> color_tuple
    end
  end

  @doc """
  Generates a random RGBA color.

  Returns a `{red, green, blue, alpha}` tuple. RGB components are integers from
  0 to 255; alpha is a float between 0.0 and 1.0.

  ## Options

    * `:format` (`nil` or `:w3c`) - when `:w3c`, returns a CSS `rgba(...)` string instead
      of a tuple. Defaults to `nil`.

  ## Examples

      iex> NeoFaker.Color.rgba()
      {255, 128, 64, 0.8}

      iex> NeoFaker.Color.rgba(format: :w3c)
      "rgba(255, 128, 64, 0.8)"

  """
  @spec rgba(keyword()) :: any_color()
  def rgba(opts \\ []) do
    opts = Options.validate!(opts, @w3c_format_schema)
    color_tuple = RgbaGenerator.color_tuple()

    case Keyword.fetch!(opts, :format) do
      :w3c -> RgbaGenerator.color_w3c(color_tuple)
      nil -> color_tuple
    end
  end

  @doc """
  Generates a random color in a randomly selected format.

  With no options, picks uniformly among CMYK, HEX, HSL, HSLA, RGB, and RGBA.

  ## Options

    * `:format` (`:w3c` or any other value) - when `:w3c`, restricts the pool to formats
      that support W3C strings (excludes HEX); any other value is passed through to each
      individual generator.

  ## Examples

      iex> NeoFaker.Color.random()
      {255, 128, 64}

      iex> NeoFaker.Color.random()
      "#613583"

  """
  @spec random(keyword()) :: any_color()
  def random(opts \\ []) do
    format_specified = Keyword.has_key?(opts, :format)

    if format_specified do
      case Keyword.fetch!(opts, :format) do
        :w3c -> Enum.random([cmyk(opts), hsl(opts), hsla(opts), rgb(opts), rgba(opts)])
        _ -> Enum.random([cmyk(opts), hex(opts), hsl(opts), hsla(opts), rgb(opts), rgba(opts)])
      end
    else
      Enum.random([cmyk(), hex(), hsl(), hsla(), rgb(), rgba()])
    end
  end
end
