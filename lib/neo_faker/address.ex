defmodule NeoFaker.Address do
  @moduledoc """
  Functions for generating address-related data.

  This module provides utilities to generate random addresses, including street names, city names,
  country names, etc.
  """
  @moduledoc since: "0.12.0"

  import NeoFaker.Data.Generator, only: [random_value: 4]

  alias NeoFaker.Number

  @city_file "city.exs"
  @country_file "country.exs"

  @doc """
  Generates a random building number within a specified range.

  Returns an integer or a string representation of the building number.

  ## Options

  - `:type` - Specifies the type of the building number to return.

  The values for `:type` can be:

  - `:string` - Returns the building number as a string (default).
  - `:integer` - Returns the building number as an integer.

  ## Examples

      iex> NeoFaker.Address.building_number(1..100)
      "25"

      iex> NeoFaker.Address.building_number(1..100, type: :integer)
      25

  """
  @spec building_number(Range.t(), keyword()) :: integer() | String.t()
  def building_number(range \\ 1..100, opts \\ []) do
    type = Keyword.get(opts, :type, :string)

    case type do
      :string ->
        range.first |> Number.between(range.last) |> Integer.to_string()

      _ ->
        Number.between(range.first, range.last)
    end
  end

  @doc """
  Generates a random city name.

  Returns a string representing a city name. If an option is provided, it uses the specified
  locale for generating the city name.

  ## Options

  The accepted options are:

  - `:locale` - Specifies the locale to use.

  Values for option `:locale` can be:

  - `nil` - Uses the default locale `:default`.
  - `:id_id` - Uses the Indonesian locale, for example.

  ## Examples

      iex> NeoFaker.Address.city()
      "Saint Marys City"

      iex> NeoFaker.Address.city(locale: :id_id)
      "Palu"

  """
  @spec city(Keyword.t()) :: String.t()
  def city(opts \\ []), do: random_value(__MODULE__, @city_file, "city", opts)

  @doc """
  Generates a random country name.

  This function behaves similarly to `city/1`, but it generates a random country name instead.
  """
  @spec country(Keyword.t()) :: String.t()
  def country(opts \\ []), do: random_value(__MODULE__, @country_file, "country", opts)

  @doc """
  Generates random geographic coordinates.

  Return a tuple of latitude and longitude, or a single value based on the specified type.

  ## Options

  The accepted options are:

  - `:type` - Specifies which coordinate(s) to return.
  - `:precision` - Number of decimal places.

  The values for `:type` can be:

  - `:full` (default) - Returns `{latitude, longitude}` tuple.
  - `:latitude` - Returns only the latitude as a float.
  - `:longitude` - Returns only the longitude as a float.

  The value for `:precision` can be any integer (default: 6), which determines the number of
  decimal places in the returned coordinates.

  ## Examples

      iex> NeoFaker.Address.coordinate()
      {11.5831672, 165.3662683

      iex> NeoFaker.Address.coordinate(type: :latitude)
      11.5831672

      iex> NeoFaker.Address.coordinate(type: :longitude)
      165.3662683

      iex> NeoFaker.Address.coordinate(precision: 2)
      {11.58, 165.37}

  """
  @spec coordinate(keyword()) :: {float(), float()} | float()
  def coordinate(opts \\ []) do
    precision = Keyword.get(opts, :precision, 6)
    type = Keyword.get(opts, :type, :full)

    latitude = Float.round(:rand.uniform() * 180 - 90, precision)
    longitude = Float.round(:rand.uniform() * 360 - 180, precision)

    case type do
      :latitude -> latitude
      :longitude -> longitude
      _ -> {latitude, longitude}
    end
  end
end
