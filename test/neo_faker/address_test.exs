defmodule NeoFaker.AddressTest do
  use ExUnit.Case, async: true

  alias NeoFaker.Address
  alias NeoFaker.Data

  @module Address

  defp fetch_cache!(locale, file) do
    locale |> Data.fetch!(@module, file) |> Map.values() |> List.flatten()
  end

  # Launders a value to an opaque type so the compiler's type checker does not
  # narrow it, letting us reach the runtime guard clauses meant for arbitrary input.
  defp opaque(term), do: Enum.random([term])

  describe "building_number/1" do
    test "returns a numeric string" do
      result = Address.building_number()

      assert is_binary(result)
      assert String.to_integer(result) in 1..100
    end

    test "stays within the given range" do
      assert String.to_integer(Address.building_number(1..10)) in 1..10
    end

    test "raises ArgumentError for a descending range" do
      assert_raise ArgumentError, ~r/first must be less than or equal to last/, fn ->
        Address.building_number(100..1//-1)
      end
    end

    test "raises ArgumentError for a non-range" do
      assert_raise ArgumentError, ~r/Expected a Range/, fn ->
        Address.building_number(opaque([1, 100]))
      end
    end
  end

  describe "city/1" do
    test "returns a random city name with no options" do
      assert Address.city() in fetch_cache!(:default, "city.exs")
    end

    test "returns a random city name" do
      city_list = fetch_cache!(:default, "city.exs")

      assert Address.city(locale: :default) in city_list
    end

    test "returns a random city name with locale" do
      city_list = fetch_cache!(:id_id, "city.exs")

      assert Address.city(locale: :id_id) in city_list
    end
  end

  describe "country/1" do
    test "returns a random country name with no options" do
      assert Address.country() in fetch_cache!(:default, "country.exs")
    end

    test "returns a random country name" do
      country_list = fetch_cache!(:default, "country.exs")

      assert Address.country(locale: :default) in country_list
    end

    test "returns a random country name with locale" do
      country_list = fetch_cache!(:id_id, "country.exs")

      assert Address.country(locale: :id_id) in country_list
    end
  end

  describe "coordinate/1" do
    test "returns a {latitude, longitude} tuple of floats within range" do
      {latitude, longitude} = Address.coordinate()

      assert is_float(latitude)
      assert is_float(longitude)
      assert latitude >= -90.0 and latitude <= 90.0
      assert longitude >= -180.0 and longitude <= 180.0
    end

    test "rounds both components to the requested precision" do
      {lat, lng} = Address.coordinate(precision: 2)

      assert decimal_places(lat) <= 2
      assert decimal_places(lng) <= 2
    end

    test "raises NimbleOptions.ValidationError for a negative precision" do
      assert_raise NimbleOptions.ValidationError, fn -> Address.coordinate(precision: -1) end
    end

    test "raises NimbleOptions.ValidationError for the removed :type option" do
      assert_raise NimbleOptions.ValidationError, fn -> Address.coordinate(type: :latitude) end
    end
  end

  describe "latitude/1 and longitude/1" do
    test "return a float in range" do
      assert Address.latitude() >= -90.0 and Address.latitude() <= 90.0
      assert Address.longitude() >= -180.0 and Address.longitude() <= 180.0
    end

    test "honour precision" do
      assert decimal_places(Address.latitude(precision: 3)) <= 3
      assert decimal_places(Address.longitude(precision: 3)) <= 3
    end
  end

  describe "Generator" do
    alias NeoFaker.Address.Generator

    test "latitude/1 and longitude/1 stay in range and honour precision" do
      for _ <- 1..50 do
        lat = Generator.latitude(3)
        lng = Generator.longitude(3)

        assert lat >= -90.0 and lat <= 90.0
        assert lng >= -180.0 and lng <= 180.0
      end
    end
  end

  describe "Validator" do
    alias NeoFaker.Address.Validator

    test "validate_range!/1 accepts an ascending range" do
      assert Validator.validate_range!(1..10) == :ok
    end

    test "validate_range!/1 rejects a descending range and a non-range" do
      assert_raise ArgumentError, fn -> Validator.validate_range!(10..1//-1) end
      assert_raise ArgumentError, fn -> Validator.validate_range!(opaque([1, 2])) end
    end
  end

  defp decimal_places(float) do
    float |> Float.to_string() |> String.split(".") |> List.last() |> String.length()
  end
end
