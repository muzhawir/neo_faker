defmodule NeoFaker.Color do
  @moduledoc """
  Functions for generating random colors.

  Colors are available in the CMYK, HEX, HSL, HSLA, RGB, and RGBA models, and as CSS
  color keywords. Functions for the numeric models return a tuple of components by
  default, or a CSS functional notation string such as `"rgb(255, 128, 64)"` when given
  `format: :w3c`.
  """
  @moduledoc since: "0.8.0"

  alias NeoFaker.Color.Generator
  alias NeoFaker.Locale

  @hex_digits [three_digit: 3, four_digit: 4, six_digit: 6, eight_digit: 8]
  @tuple_models [:cmyk, :hsl, :hsla, :rgb, :rgba]

  @format_schema NimbleOptions.new!(format: [type: {:in, [nil, :w3c]}, default: nil])

  @hex_schema NimbleOptions.new!(
                format: [type: {:in, Keyword.keys(@hex_digits)}, default: :six_digit]
              )

  @keyword_schema NimbleOptions.new!(
                    category: [type: {:in, [:all, :basic, :extended]}, default: :all],
                    locale: [type: {:custom, Locale, :validate_option, []}, default: nil]
                  )

  @typedoc """
  A color returned by this module: a tuple of numeric components, or a string.
  """
  @type color :: tuple() | String.t()

  @doc """
  Generates a random CMYK color.

  Returns a `{cyan, magenta, yellow, key}` tuple of integer percentages from `0` to
  `100`.

  ## Options

    * `:format` (`nil` or `:w3c`) - when `:w3c`, returns a CSS `cmyk()` string instead
      of a tuple. Defaults to `nil`.

  ## Examples

      iex> NeoFaker.Color.cmyk()
      {0, 25, 50, 100}

      iex> NeoFaker.Color.cmyk(format: :w3c)
      "cmyk(0%, 25%, 50%, 100%)"

  """
  @spec cmyk(keyword()) :: color()
  def cmyk(opts \\ []), do: tuple_color(:cmyk, opts)

  @doc """
  Generates a random HEX color string.

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

  ## Options

    * `:format` (`nil` or `:w3c`) - when `:w3c`, returns a CSS `hsl()` string instead of
      a tuple. Defaults to `nil`.

  ## Examples

      iex> NeoFaker.Color.hsl()
      {180, 50, 75}

      iex> NeoFaker.Color.hsl(format: :w3c)
      "hsl(180, 50%, 75%)"

  """
  @spec hsl(keyword()) :: color()
  def hsl(opts \\ []), do: tuple_color(:hsl, opts)

  @doc """
  Generates a random HSLA color.

  Returns a `{hue, saturation, lightness, alpha}` tuple. The first three components are
  as in `hsl/1`; alpha is a float from `0.0` to `1.0` with one decimal place.

  ## Options

    * `:format` (`nil` or `:w3c`) - when `:w3c`, returns a CSS `hsla()` string instead of
      a tuple. Defaults to `nil`.

  ## Examples

      iex> NeoFaker.Color.hsla()
      {180, 50, 75, 0.8}

      iex> NeoFaker.Color.hsla(format: :w3c)
      "hsla(180, 50%, 75%, 0.8)"

  """
  @spec hsla(keyword()) :: color()
  def hsla(opts \\ []), do: tuple_color(:hsla, opts)

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

  Returns a `{red, green, blue}` tuple of integers from `0` to `255`.

  ## Options

    * `:format` (`nil` or `:w3c`) - when `:w3c`, returns a CSS `rgb()` string instead of
      a tuple. Defaults to `nil`.

  ## Examples

      iex> NeoFaker.Color.rgb()
      {255, 128, 64}

      iex> NeoFaker.Color.rgb(format: :w3c)
      "rgb(255, 128, 64)"

  """
  @spec rgb(keyword()) :: color()
  def rgb(opts \\ []), do: tuple_color(:rgb, opts)

  @doc """
  Generates a random RGBA color.

  Returns a `{red, green, blue, alpha}` tuple. The first three components are as in
  `rgb/1`; alpha is a float from `0.0` to `1.0` with one decimal place.

  ## Options

    * `:format` (`nil` or `:w3c`) - when `:w3c`, returns a CSS `rgba()` string instead of
      a tuple. Defaults to `nil`.

  ## Examples

      iex> NeoFaker.Color.rgba()
      {255, 128, 64, 0.8}

      iex> NeoFaker.Color.rgba(format: :w3c)
      "rgba(255, 128, 64, 0.8)"

  """
  @spec rgba(keyword()) :: color()
  def rgba(opts \\ []), do: tuple_color(:rgba, opts)

  @doc """
  Generates a random color in a randomly chosen model.

  Picks uniformly between CMYK, HEX, HSL, HSLA, RGB, and RGBA, and generates a single
  color in that model.

  ## Options

    * `:format` (`nil` or `:w3c`) - when `:w3c`, excludes HEX and returns a CSS string
      from one of the other models. Defaults to `nil`.

  ## Examples

      iex> NeoFaker.Color.random()
      {255, 128, 64}

      iex> NeoFaker.Color.random(format: :w3c)
      "hsl(180, 50%, 75%)"

  """
  @spec random(keyword()) :: color()
  def random(opts \\ []) do
    opts = NimbleOptions.validate!(opts, @format_schema)

    case Keyword.fetch!(opts, :format) do
      :w3c -> @tuple_models |> Enum.random() |> tuple_color(opts)
      nil -> [:hex | @tuple_models] |> Enum.random() |> random_color()
    end
  end

  defp random_color(:hex), do: hex()
  defp random_color(model), do: tuple_color(model, [])

  defp tuple_color(model, opts) do
    color = Generator.color(model)

    case opts |> NimbleOptions.validate!(@format_schema) |> Keyword.fetch!(:format) do
      nil -> color
      :w3c -> Generator.to_w3c(model, color)
    end
  end
end
