defmodule NeoFaker.AddressTest do
  use ExUnit.Case, async: true

  alias NeoFaker.Data.Cache

  @module NeoFaker.Address
  @city_file "city.exs"
  @country_file "country.exs"

  defp fetch_cache!(locale, module, file) do
    locale |> Cache.fetch!(module, file) |> Map.values() |> List.flatten()
  end

  describe "building_number/2" do
    test "returns a random integer building number" do
      assert is_integer(NeoFaker.Address.building_number(1..100, type: :integer))
    end

    test "return a random string building number" do
      assert is_binary(NeoFaker.Address.building_number(1..100, type: :string))
    end

    test "return a random integer building number with specific range" do
      assert NeoFaker.Address.building_number(1..100, type: :integer) in 1..100
    end
  end

  describe "city/1" do
    test "returns a random city name" do
      city_list = fetch_cache!(:default, @module, @city_file)

      assert NeoFaker.Address.city() in city_list
    end

    test "returns a random city name with locale" do
      city_list = fetch_cache!(:id_id, @module, @city_file)

      assert NeoFaker.Address.city(locale: :id_id) in city_list
    end
  end

  describe "country/1" do
    test "returns a random country name" do
      country_list = fetch_cache!(:default, @module, @country_file)

      assert NeoFaker.Address.country() in country_list
    end

    test "returns a random country name with locale" do
      country_list = fetch_cache!(:id_id, @module, @country_file)

      assert NeoFaker.Address.country(locale: :id_id) in country_list
    end
  end

  describe "coordinate/1" do
    test "returns a random coordinate" do
      assert is_tuple(NeoFaker.Address.coordinate())
      {latitude, longitude} = NeoFaker.Address.coordinate()

      assert is_float(latitude)
      assert is_float(longitude)
      assert latitude >= -90.0 and latitude <= 90.0
      assert longitude >= -180.0 and longitude <= 180.0
    end

    test "returns only a random latitude/longitude" do
      assert is_float(NeoFaker.Address.coordinate(type: :latitude))
      assert is_float(NeoFaker.Address.coordinate(type: :longitude))
    end
  end
end
