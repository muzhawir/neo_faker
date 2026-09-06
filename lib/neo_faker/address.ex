defmodule NeoFaker.Address do
  @moduledoc """
  Functions for generating random address data.

  Provides utilities to generate street names, city names, country names, building numbers, and
  geographic coordinates with support for multiple locales.
  """
  @moduledoc since: "0.12.0"

  alias NeoFaker.Address.Generator
  alias NeoFaker.Address.Validator
  alias NeoFaker.Data
  alias NeoFaker.Helpers.Formatter
  alias NeoFaker.Helpers.Options
  alias NeoFaker.Number

  @city_file "city.exs"
  @country_file "country.exs"

  @building_number_range 1..100
  @coordinate_precision 6

  @building_number_schema NimbleOptions.new!(
                            type: [
                              type: {:custom, Validator, :validate_building_number_type, []},
                              default: :string
                            ]
                          )

  @locale_schema NimbleOptions.new!(locale: [type: :atom, default: nil])

  @coordinate_schema NimbleOptions.new!(
                       type: [
                         type: {:custom, Validator, :validate_coordinate_type, []},
                         default: :full
                       ],
                       precision: [type: :non_neg_integer, default: @coordinate_precision]
                     )

  @doc """
  Generates a random building number within a specified range.

  Returns the building number as a string by default, or as an integer when `type: :integer` is
  passed.

  ## Parameters

  - `range` - The range of building numbers. Defaults to `1..100`.
  - `opts` - Keyword list of options:
    - `:type` - Return type. Either `:string` (default) or `:integer`.

  ## Examples

      iex> NeoFaker.Address.building_number()
      "42"

      iex> NeoFaker.Address.building_number(1..100, type: :integer)
      25

  """
  @spec building_number(Range.t(), keyword()) :: integer() | String.t()
  def building_number(range \\ @building_number_range, opts \\ []) do
    Validator.validate_range!(range)
    opts = Options.validate!(opts, @building_number_schema)

    number = Number.between(range.first, range.last)

    case Keyword.fetch!(opts, :type) do
      :string -> Formatter.format_number(number, :string)
      :integer -> number
    end
  end

  @doc """
  Generates a random city name.

  The city name is selected from locale-specific data. Pass `locale:` to use a different locale.
  See the [available locales](https://hexdocs.pm/neo_faker/locales.html) for supported codes.

  ## Examples

      iex> NeoFaker.Address.city()
      "Saint Marys City"

      iex> NeoFaker.Address.city(locale: :id_id)
      "Palu"

  """
  @spec city(keyword()) :: String.t()
  def city(opts \\ []) do
    opts = Options.validate!(opts, @locale_schema)
    Data.random_value(__MODULE__, @city_file, "city", opts)
  end

  @doc """
  Generates a random country name.

  The country name is selected from locale-specific data. Pass `locale:` to use a different
  locale. See the [available locales](https://hexdocs.pm/neo_faker/locales.html) for supported
  codes.

  ## Examples

      iex> NeoFaker.Address.country()
      "United States"

      iex> NeoFaker.Address.country(locale: :id_id)
      "Indonesia"

  """
  @spec country(keyword()) :: String.t()
  def country(opts \\ []) do
    opts = Options.validate!(opts, @locale_schema)
    Data.random_value(__MODULE__, @country_file, "country", opts)
  end

  @doc """
  Generates random geographic coordinates.

  Returns a `{latitude, longitude}` tuple by default. Use the `:type` option to return a single
  value, and `:precision` to control decimal places.

  ## Parameters

  - `opts` - Keyword list of options:
    - `:type` - Which coordinate(s) to return. Defaults to `:full`.
    - `:precision` - Number of decimal places. Defaults to `6`.

  ## Options

  The values for `:type` can be:

  - `:full` - Returns `{latitude, longitude}` tuple (default).
  - `:latitude` - Returns only the latitude as a float.
  - `:longitude` - Returns only the longitude as a float.

  ## Examples

      iex> NeoFaker.Address.coordinate()
      {11.5831672, 165.3662683}

      iex> NeoFaker.Address.coordinate(type: :latitude)
      11.5831672

      iex> NeoFaker.Address.coordinate(type: :longitude)
      165.3662683

      iex> NeoFaker.Address.coordinate(precision: 2)
      {11.58, 165.37}

      iex> NeoFaker.Address.coordinate(type: :latitude, precision: 4)
      11.5832

  """
  @spec coordinate(keyword()) :: {float(), float()} | float()
  def coordinate(opts \\ []) do
    opts = Options.validate!(opts, @coordinate_schema)

    latitude = Generator.latitude(Keyword.fetch!(opts, :precision))
    longitude = Generator.longitude(Keyword.fetch!(opts, :precision))

    case Keyword.fetch!(opts, :type) do
      :latitude -> latitude
      :longitude -> longitude
      :full -> {latitude, longitude}
    end
  end
end
