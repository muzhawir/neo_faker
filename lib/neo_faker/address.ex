defmodule NeoFaker.Address do
  @moduledoc """
  Provides functions for generating random address data.

  This module offers utilities to create random addresses, such as street names, city names,
  country names, building numbers, and geographic coordinates.
  """
  @moduledoc since: "0.12.0"

  import NeoFaker.Data.Generator, only: [random_value: 4]

  alias NeoFaker.Helpers.Constants
  alias NeoFaker.Helpers.Formatter
  alias NeoFaker.Helpers.Options
  alias NeoFaker.Number

  @doc """
  Generates a random building number within a specified range.

  Returns an integer or a string representation of the building number based on
  the specified type.

  ## Parameters

  - `range` - The range of building numbers. Defaults to `1..100`.
  - `opts` - Keyword list of options:
    - `:type` - Specifies the return type (`:string` or `:integer`). Defaults to `:string`.

  ## Options

  The values for `:type` can be:

  - `:string` - Returns the building number as a string (default).
  - `:integer` - Returns the building number as an integer.

  ## Examples

      iex> NeoFaker.Address.building_number(1..100)
      "25"

      iex> NeoFaker.Address.building_number(1..100, type: :integer)
      25

      iex> NeoFaker.Address.building_number()
      "42"

      iex> NeoFaker.Address.building_number(1..10, type: :string)
      "7"

  """
  @spec building_number(Range.t(), keyword()) :: integer() | String.t()
  def building_number(range \\ Constants.default_building_number_range(), opts \\ []) do
    validate_range!(range)

    type = Options.get(opts, :type, :string)
    number = Number.between(range.first, range.last)

    case type do
      :string -> Formatter.format_number(number, :string)
      :integer -> number
      _ -> Formatter.format_number(number, :string)
    end
  end

  @doc """
  Generates a random city name.

  Returns a string representing a city name. The city name is selected from
  locale-specific data files.

  ## Parameters

  - `opts` - Keyword list of options:
    - `:locale` - Specifies the locale to use. Defaults to the application's current locale.

  ## Options

  Values for option `:locale` can be:

  - `nil` - Uses the default locale `:default`.
  - `:id_id` - Uses the Indonesian locale. For a list of supported locales, see
    [list of supported locales](https://hexdocs.pm/neo_faker/available-locales.html).

  ## Examples

      iex> NeoFaker.Address.city()
      "Saint Marys City"

      iex> NeoFaker.Address.city(locale: :id_id)
      "Palu"

  """
  @spec city(Keyword.t()) :: String.t()
  def city(opts \\ []), do: random_value(__MODULE__, Constants.city_file(), "city", opts)

  @doc """
  Generates a random country name.

  Returns a string representing a country name. The country name is selected from
  locale-specific data files.

  ## Parameters

  - `opts` - Keyword list of options:
    - `:locale` - Specifies the locale to use. Defaults to the application's current locale.

  ## Options

  Values for option `:locale` can be:

  - `nil` - Uses the default locale `:default`.
  - `:id_id` - Uses the Indonesian locale. For a list of supported locales, see
    [list of supported locales](https://hexdocs.pm/neo_faker/available-locales.html).

  ## Examples

      iex> NeoFaker.Address.country()
      "United States"

      iex> NeoFaker.Address.country(locale: :id_id)
      "Indonesia"

  """
  @spec country(Keyword.t()) :: String.t()
  def country(opts \\ []) do
    random_value(__MODULE__, Constants.country_file(), "country", opts)
  end

  @doc """
  Generates random geographic coordinates.

  Returns a tuple of latitude and longitude, or a single value based on the specified type.
  Coordinates are generated with configurable precision.

  ## Parameters

  - `opts` - Keyword list of options:
    - `:type` - Specifies which coordinate(s) to return. Defaults to `:full`.
    - `:precision` - Number of decimal places. Defaults to `6`.

  ## Options

  The values for `:type` can be:

  - `:full` (default) - Returns `{latitude, longitude}` tuple.
  - `:latitude` - Returns only the latitude as a float.
  - `:longitude` - Returns only the longitude as a float.

  The value for `:precision` can be any non-negative integer (default: 6), which
  determines the number of decimal places in the returned coordinates.

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
    precision = Options.get(opts, :precision, Constants.default_coordinate_precision())
    type = Options.get(opts, :type, :full)

    validate_precision!(precision)

    latitude = generate_latitude(precision)
    longitude = generate_longitude(precision)

    case type do
      :latitude -> latitude
      :longitude -> longitude
      :full -> {latitude, longitude}
      _ -> {latitude, longitude}
    end
  end

  # Private functions

  @spec generate_latitude(non_neg_integer()) :: float()
  defp generate_latitude(precision) do
    # Latitude ranges from -90 to 90
    Float.round(:rand.uniform() * 180 - 90, precision)
  end

  @spec generate_longitude(non_neg_integer()) :: float()
  defp generate_longitude(precision) do
    # Longitude ranges from -180 to 180
    Float.round(:rand.uniform() * 360 - 180, precision)
  end

  @spec validate_range!(Range.t()) :: :ok
  defp validate_range!(range) when is_struct(range, Range) do
    if range.first <= range.last do
      :ok
    else
      raise ArgumentError, "Invalid range: first must be less than or equal to last"
    end
  end

  defp validate_range!(invalid) do
    raise ArgumentError, "Expected a Range, got: #{inspect(invalid)}"
  end

  @spec validate_precision!(integer()) :: :ok
  defp validate_precision!(precision) when is_integer(precision) and precision >= 0, do: :ok

  defp validate_precision!(precision) when is_integer(precision) do
    raise ArgumentError, "precision must be non-negative, got: #{precision}"
  end

  defp validate_precision!(invalid) do
    raise ArgumentError, "precision must be an integer, got: #{inspect(invalid)}"
  end
end
