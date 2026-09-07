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

  describe "building_number/2" do
    test "returns a string by default" do
      assert is_binary(Address.building_number())
    end

    test "returns a random integer building number" do
      assert is_integer(Address.building_number(1..100, type: :integer))
    end

    test "returns a random string building number" do
      assert is_binary(Address.building_number(1..100, type: :string))
    end

    test "returns a random integer building number within the specified range" do
      assert Address.building_number(1..100, type: :integer) in 1..100
    end

    test "raises NimbleOptions.ValidationError for an unknown :type" do
      assert_raise NimbleOptions.ValidationError, ~r/invalid :type for building_number\/2/, fn ->
        Address.building_number(1..100, type: :float)
      end
    end

    test "raises NimbleOptions.ValidationError for a non-atom :type" do
      assert_raise NimbleOptions.ValidationError, ~r/invalid :type for building_number\/2/, fn ->
        Address.building_number(1..100, type: "string")
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
    test "returns a {latitude, longitude} tuple by default" do
      assert {_lat, _lng} = Address.coordinate()
    end

    test "returns a random coordinate as a tuple of floats" do
      {latitude, longitude} = Address.coordinate()

      assert is_float(latitude)
      assert is_float(longitude)
      assert latitude >= -90.0 and latitude <= 90.0
      assert longitude >= -180.0 and longitude <= 180.0
    end

    test "returns only a random latitude as a float" do
      assert is_float(Address.coordinate(type: :latitude))
    end

    test "returns only a random longitude as a float" do
      assert is_float(Address.coordinate(type: :longitude))
    end

    test "raises NimbleOptions.ValidationError for an unknown :type" do
      assert_raise NimbleOptions.ValidationError, ~r/invalid :type for coordinate\/1/, fn ->
        Address.coordinate(type: :altitude)
      end
    end

    test "raises NimbleOptions.ValidationError for a non-atom :type" do
      assert_raise NimbleOptions.ValidationError, ~r/invalid :type for coordinate\/1/, fn ->
        Address.coordinate(type: "full")
      end
    end

    test "rounds to the requested precision" do
      lat = Address.coordinate(type: :latitude, precision: 2)
      decimals = lat |> Float.to_string() |> String.split(".") |> List.last() |> String.length()

      assert decimals <= 2
    end

    test "raises NimbleOptions.ValidationError for a negative precision" do
      assert_raise NimbleOptions.ValidationError, fn -> Address.coordinate(precision: -1) end
    end
  end

  describe "building_number/2 range validation" do
    test "uses the default 1..100 range" do
      assert Address.building_number(1..100, type: :integer) in 1..100
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

    test "validate_building_number_type/1 and validate_coordinate_type/1 round-trip valid values" do
      assert Validator.validate_building_number_type(:integer) == {:ok, :integer}
      assert {:error, _} = Validator.validate_building_number_type(:float)
      assert Validator.validate_coordinate_type(:latitude) == {:ok, :latitude}
      assert {:error, _} = Validator.validate_coordinate_type(:altitude)
    end
  end
end
