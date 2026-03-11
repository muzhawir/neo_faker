defmodule NeoFaker.Address do
  @moduledoc """
  Functions for generating random address data.

  Provides utilities to generate street names, city names, country names, building
  numbers, and geographic coordinates with support for multiple locales.
  """
  @moduledoc since: "0.12.0"

  import NeoFaker.Data, only: [random_value: 4]

  alias NeoFaker.Helpers.Constants
  alias NeoFaker.Helpers.Formatter
  alias NeoFaker.Helpers.Options
  alias NeoFaker.Number

  @doc """
  Generates a random building number within a specified range.

  Returns the building number as a string by default, or as an integer when
  `type: :integer` is passed.

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

  The city name is selected from locale-specific data. Pass `locale:` to use a
  different locale. See the
  [available locales](https://hexdocs.pm/neo_faker/available-locales.html)
  for supported codes.

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

  The country name is selected from locale-specific data. Pass `locale:` to use a
  different locale. See the
  [available locales](https://hexdocs.pm/neo_faker/available-locales.html)
  for supported codes.

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

  Returns a `{latitude, longitude}` tuple by default. Use the `:type` option to
  return a single value, and `:precision` to control decimal places.

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
