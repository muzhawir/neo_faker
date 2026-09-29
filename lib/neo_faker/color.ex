defmodule NeoFaker.Color do
  @moduledoc """
  Functions for generating random colors.

  Each color model has a function that returns its components as a tuple: `cmyk/0`,
  `hsl/0`, `hsla/0`, `rgb/0`, and `rgba/0`. To get a color as a string instead, use
  `css/1` for CSS notation, `hex/1` for a hex code, or `keyword/1` for a CSS color
  keyword.
  """
  @moduledoc since: "0.8.0"

  alias NeoFaker.Color.Generator
  alias NeoFaker.Color.Validator
  alias NeoFaker.Locale

  @hex_digits [three_digit: 3, four_digit: 4, six_digit: 6, eight_digit: 8]

  # `css/0` leaves out `:cmyk`: `device-cmyk()` is meant for print and is not a
  # color browsers render, so a random web color never uses it.
  @random_notations [:hex, :rgb, :rgba, :hsl, :hsla]
  @notations [:random, :cmyk | @random_notations]
  @tuple_models [:cmyk, :hsl, :hsla, :rgb, :rgba]

  @hex_schema NimbleOptions.new!(
                format: [type: {:in, Keyword.keys(@hex_digits)}, default: :six_digit]
              )

  @keyword_schema NimbleOptions.new!(
                    category: [type: {:in, [:all, :basic, :extended]}, default: :all],
                    locale: [type: {:custom, Locale, :validate_option, []}, default: nil]
                  )

  @doc """
  Generates a random CMYK color.

  Returns a `{cyan, magenta, yellow, key}` tuple of integer percentages from `0` to
  `100`. Use `css(:cmyk)` for CSS notation.

  ## Examples

      iex> NeoFaker.Color.cmyk()
      {0, 25, 50, 100}

  """
  @spec cmyk() :: {0..100, 0..100, 0..100, 0..100}
  def cmyk, do: Generator.color(:cmyk)

  @doc """
  Generates a random color in CSS notation.

  `notation` selects the notation and defaults to `:random`, which picks one of `:hex`,
  `:rgb`, `:rgba`, `:hsl`, or `:hsla` for each call.

    * `:hex` - a six-digit hex code, as `hex/1` returns by default.
    * `:rgb`, `:rgba` - the `rgb()` and `rgba()` functions, with components as in
      `rgb/0` and `rgba/0`.
    * `:hsl`, `:hsla` - the `hsl()` and `hsla()` functions, with components as in
      `hsl/0` and `hsla/0`.
    * `:cmyk` - the `device-cmyk()` function from CSS Color 5, with components as in
      `cmyk/0`. It describes print colors and is never picked by `:random`.

  Raises `ArgumentError` for any other `notation`.

  ## Examples

      iex> NeoFaker.Color.css()
      "hsl(180, 50%, 75%)"

      iex> NeoFaker.Color.css(:rgb)
      "rgb(255, 128, 64)"

      iex> NeoFaker.Color.css(:hsla)
      "hsla(180, 50%, 75%, 0.8)"

      iex> NeoFaker.Color.css(:cmyk)
      "device-cmyk(0% 25% 50% 100%)"

  """
  @doc since: "0.16.0"
  @spec css(:random | :hex | :rgb | :rgba | :hsl | :hsla | :cmyk) :: String.t()
  def css(notation \\ :random) do
    case Validator.validate_notation!(notation, @notations) do
      :random -> @random_notations |> Enum.random() |> css()
      :hex -> hex()
      model when model in @tuple_models -> Generator.to_css(model, Generator.color(model))
    end
  end

  @doc """
  Generates a random hex color code.

  Digits are uppercase and the string starts with `#`.

  ## Options

    * `:format` (`:three_digit`, `:four_digit`, `:six_digit`, or `:eight_digit`) - the
      number of hex digits. The four- and eight-digit forms include an alpha channel.
      Defaults to `:six_digit`.

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
    format = opts |> NimbleOptions.validate!(@hex_schema) |> Keyword.fetch!(:format)
    "#" <> Generator.hex(Keyword.fetch!(@hex_digits, format))
  end

  @doc """
  Generates a random HSL color.

  Returns a `{hue, saturation, lightness}` tuple. The hue is an integer angle from `0`
  to `359` degrees; saturation and lightness are integer percentages from `0` to `100`.
  Use `css(:hsl)` for CSS notation.

  ## Examples

      iex> NeoFaker.Color.hsl()
      {180, 50, 75}

  """
  @spec hsl() :: {0..359, 0..100, 0..100}
  def hsl, do: Generator.color(:hsl)

  @doc """
  Generates a random HSLA color.

  Returns a `{hue, saturation, lightness, alpha}` tuple. The first three components are
  as in `hsl/0`; alpha is a float from `0.0` to `1.0` with one decimal place. Use
  `css(:hsla)` for CSS notation.

  ## Examples

      iex> NeoFaker.Color.hsla()
      {180, 50, 75, 0.8}

  """
  @spec hsla() :: {0..359, 0..100, 0..100, float()}
  def hsla, do: Generator.color(:hsla)

  @doc """
  Generates a random CSS color keyword, such as `"blueviolet"`.

  ## Options

    * `:category` (`:all`, `:basic`, or `:extended`) - the keyword set to draw from.
      `:basic` holds the 16 CSS Level 1 colors; `:extended` holds the full CSS named color
      list. Defaults to `:all`.
    * `:locale` (atom) - the locale to use. Defaults to the active locale, see
      `NeoFaker.Locale`.

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
    opts = NimbleOptions.validate!(opts, @keyword_schema)
    Generator.keyword(Keyword.fetch!(opts, :category), Keyword.fetch!(opts, :locale))
  end

  @doc """
  Generates a random RGB color.

  Returns a `{red, green, blue}` tuple of integers from `0` to `255`. Use `css(:rgb)`
  for CSS notation.

  ## Examples

      iex> NeoFaker.Color.rgb()
      {255, 128, 64}

  """
  @spec rgb() :: {0..255, 0..255, 0..255}
  def rgb, do: Generator.color(:rgb)

  @doc """
  Generates a random RGBA color.

  Returns a `{red, green, blue, alpha}` tuple. The first three components are as in
  `rgb/0`; alpha is a float from `0.0` to `1.0` with one decimal place. Use `css(:rgba)`
  for CSS notation.

  ## Examples

      iex> NeoFaker.Color.rgba()
      {255, 128, 64, 0.8}

  """
  @spec rgba() :: {0..255, 0..255, 0..255, float()}
  def rgba, do: Generator.color(:rgba)
end
