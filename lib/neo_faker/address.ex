defmodule NeoFaker.Address do
  @moduledoc """
  Functions for generating addresses and geographic coordinates.

  City and country names are drawn from locale-specific data. Coordinates are uniformly
  distributed over the valid latitude and longitude ranges.
  """
  @moduledoc since: "0.12.0"

  alias NeoFaker.Address.Generator
  alias NeoFaker.Data
  alias NeoFaker.Helpers.Validator
  alias NeoFaker.Locale

  @city_file "city.exs"
  @country_file "country.exs"

  @locale_schema NimbleOptions.new!(
                   locale: [type: {:custom, Locale, :validate_option, []}, default: nil]
                 )

  # `Float.round/2` only supports up to 15 decimal places.
  @precision_schema NimbleOptions.new!(precision: [type: {:in, 0..15}, default: 6])

  @doc """
  Generates a random building number within `range`, as a string.

  `range` defaults to `1..100`. Use `String.to_integer/1` on the result if you need an
  integer.

  Raises `ArgumentError` if `range` is not a non-empty range.

  ## Examples

      iex> NeoFaker.Address.building_number()
      "42"

      iex> NeoFaker.Address.building_number(1..9)
      "7"

  """
  @spec building_number(Range.t()) :: String.t()
  def building_number(range \\ 1..100) do
    range
    |> Validator.validate_range!("range")
    |> Enum.random()
    |> Integer.to_string()
  end

  @doc """
  Generates a random city name.

  ## Options

    * `:locale` (atom) - the locale to use. Defaults to the active locale, see
      `NeoFaker.Locale`.

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

  ## Options

    * `:locale` (atom) - the locale to use. Defaults to the active locale, see
      `NeoFaker.Locale`.

  ## Examples

      iex> NeoFaker.Address.country()
      "United States"

      iex> NeoFaker.Address.country(locale: :id_id)
      "Amerika Serikat"

  """
  @spec country(keyword()) :: String.t()
  def country(opts \\ []) do
    opts = NimbleOptions.validate!(opts, @locale_schema)
    Data.random_value(__MODULE__, @country_file, "country", opts)
  end

  @doc """
  Generates a random `{latitude, longitude}` pair.

  Use `latitude/1` or `longitude/1` for a single component.

  ## Options

    * `:precision` (integer from `0` to `15`) - the number of decimal places.
      Defaults to `6`.

  ## Examples

      iex> NeoFaker.Address.coordinate()
      {11.583167, 165.366268}

      iex> NeoFaker.Address.coordinate(precision: 2)
      {11.58, 165.37}

  """
  @spec coordinate(keyword()) :: {float(), float()}
  def coordinate(opts \\ []) do
    precision = precision!(opts)
    {Generator.latitude(precision), Generator.longitude(precision)}
  end

  @doc """
  Generates a random latitude between `-90.0` and `90.0`.

  ## Options

    * `:precision` (integer from `0` to `15`) - the number of decimal places.
      Defaults to `6`.

  ## Examples

      iex> NeoFaker.Address.latitude()
      11.583167

      iex> NeoFaker.Address.latitude(precision: 4)
      11.5832

  """
  @spec latitude(keyword()) :: float()
  def latitude(opts \\ []), do: opts |> precision!() |> Generator.latitude()

  @doc """
  Generates a random longitude between `-180.0` and `180.0`.

  ## Options

    * `:precision` (integer from `0` to `15`) - the number of decimal places.
      Defaults to `6`.

  ## Examples

      iex> NeoFaker.Address.longitude()
      165.366268

      iex> NeoFaker.Address.longitude(precision: 4)
      165.3663

  """
  @spec longitude(keyword()) :: float()
  def longitude(opts \\ []), do: opts |> precision!() |> Generator.longitude()

  defp precision!(opts) do
    opts |> NimbleOptions.validate!(@precision_schema) |> Keyword.fetch!(:precision)
  end
end
