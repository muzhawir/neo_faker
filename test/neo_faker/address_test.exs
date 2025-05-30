defmodule NeoFaker.AddressTest do
  use ExUnit.Case, async: true

  alias NeoFaker.Data.Cache

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

  describe "city/0" do
    test "returns a random city name" do
      city_list = fetch_cache!(:default, NeoFaker.Address, "city.exs")

      assert NeoFaker.Address.city() in city_list
    end

    test "returns a random city name with locale" do
      city_list = fetch_cache!(:id_id, NeoFaker.Address, "city.exs")

      assert NeoFaker.Address.city(locale: :id_id) in city_list
    end
  end
end
