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

  @city_file "city.exs"
  @country_file "country.exs"

  @building_number_range 1..100
  @coordinate_precision 6

  @locale_schema NimbleOptions.new!(locale: [type: :atom, default: nil])

  @precision_schema NimbleOptions.new!(
                      precision: [type: :non_neg_integer, default: @coordinate_precision]
                    )

  @doc """
  Generates a random building number within the given `range`, as a string.

  `range` defaults to `1..100`. Call `String.to_integer/1` yourself if you need an integer.

  ## Examples

      iex> NeoFaker.Address.building_number()
      "42"

      iex> NeoFaker.Address.building_number(1..100)
      "25"

  """
  @spec building_number(Range.t()) :: String.t()
  def building_number(range \\ @building_number_range) do
    Validator.validate_range!(range)

    range |> Enum.random() |> Integer.to_string()
  end

  @doc """
  Generates a random city name.

  The city name is selected from locale-specific data. See the
  [available locales](https://hexdocs.pm/neo_faker/locales.html) for supported codes.

  ## Options

    * `:locale` (atom) - the locale to use. Defaults to the application's configured locale.

  ## Examples

      iex> NeoFaker.Address.city()
      "Saint Marys City"

      iex> NeoFaker.Address.city(locale: :id_id)
      "Palu"

  """
  @spec city(keyword()) :: String.t()
  def city(opts \\ []) do
    opts = NimbleOptions.validate!(opts, @locale_schema)
    Data.random_value(__MODULE__, @city_file, "city", opts)
  end

  @doc """
  Generates a random country name.

  The country name is selected from locale-specific data. See the
  [available locales](https://hexdocs.pm/neo_faker/locales.html) for supported codes.

  ## Options

    * `:locale` (atom) - the locale to use. Defaults to the application's configured locale.

  ## Examples

      iex> NeoFaker.Address.country()
      "United States"

      iex> NeoFaker.Address.country(locale: :id_id)
      "Indonesia"

  """
  @spec country(keyword()) :: String.t()
  def country(opts \\ []) do
    opts = NimbleOptions.validate!(opts, @locale_schema)
    Data.random_value(__MODULE__, @country_file, "country", opts)
  end

  @doc """
  Generates a random `{latitude, longitude}` coordinate pair.

  For a single component, use `latitude/1` or `longitude/1`.

  ## Options

    * `:precision` (non-negative integer) - the number of decimal places. Defaults to `6`.

  ## Examples

      iex> NeoFaker.Address.coordinate()
      {11.5831672, 165.3662683}

      iex> NeoFaker.Address.coordinate(precision: 2)
      {11.58, 165.37}

  """
  @spec coordinate(keyword()) :: {float(), float()}
  def coordinate(opts \\ []) do
    precision = opts |> NimbleOptions.validate!(@precision_schema) |> Keyword.fetch!(:precision)

    {Generator.latitude(precision), Generator.longitude(precision)}
  end

  @doc """
  Generates a random latitude between `-90.0` and `90.0`.

  ## Options

    * `:precision` (non-negative integer) - the number of decimal places. Defaults to `6`.

  ## Examples

      iex> NeoFaker.Address.latitude()
      11.5831672

      iex> NeoFaker.Address.latitude(precision: 4)
      11.5832

  """
  @spec latitude(keyword()) :: float()
  def latitude(opts \\ []) do
    precision = opts |> NimbleOptions.validate!(@precision_schema) |> Keyword.fetch!(:precision)

    Generator.latitude(precision)
  end

  @doc """
  Generates a random longitude between `-180.0` and `180.0`.

  ## Options

    * `:precision` (non-negative integer) - the number of decimal places. Defaults to `6`.

  ## Examples

      iex> NeoFaker.Address.longitude()
      165.3662683

      iex> NeoFaker.Address.longitude(precision: 4)
      165.3663

  """
  @spec longitude(keyword()) :: float()
  def longitude(opts \\ []) do
    precision = opts |> NimbleOptions.validate!(@precision_schema) |> Keyword.fetch!(:precision)

    Generator.longitude(precision)
  end
end
