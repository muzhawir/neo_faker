defmodule NeoFaker.HTTPTest do
  use ExUnit.Case, async: true

  alias NeoFaker.Data
  alias NeoFaker.HTTP

  @all_groups [:information, :success, :redirection, :client_error, :server_error]

  defp fetch_status_codes, do: Data.fetch!(:default, HTTP, "status_code.exs")

  defp all_status_codes, do: fetch_status_codes() |> Map.values() |> List.flatten()

  defp status_code_numbers do
    Enum.map(all_status_codes(), fn code ->
      code |> String.split(" ", parts: 2) |> List.first()
    end)
  end

  defp status_codes_for_group(group) do
    Map.get(fetch_status_codes(), Atom.to_string(group))
  end

  describe "user_agent/0" do
    test "returns a valid user agent string" do
      result = HTTP.user_agent()

      assert is_binary(result)
      assert String.valid?(result)
      refute result == ""
    end
  end

  describe "request_method/0" do
    test "returns one of the standard HTTP request methods" do
      assert HTTP.request_method() in ["GET", "POST", "PUT", "DELETE", "PATCH"]
    end
  end

  describe "referrer_policy/0" do
    test "returns a valid referrer policy string" do
      valid_policies = [
        "no-referrer",
        "no-referrer-when-downgrade",
        "same-origin",
        "origin",
        "strict-origin",
        "origin-when-cross-origin",
        "strict-origin-when-cross-origin",
        "unsafe-url"
      ]

      assert HTTP.referrer_policy() in valid_policies
    end
  end

  describe "status_code/1" do
    test "returns a detailed status code string" do
      assert HTTP.status_code(type: :detailed) in all_status_codes()
    end

    test "returns a simple numeric status code string" do
      assert HTTP.status_code(type: :simple) in status_code_numbers()
    end

    test "returns a detailed status code for each group" do
      for group <- @all_groups do
        assert HTTP.status_code(group: group, type: :detailed) in status_codes_for_group(group)
      end
    end

    test "returns a simple status code for each group" do
      for group <- @all_groups do
        group_numbers =
          group
          |> status_codes_for_group()
          |> Enum.map(fn code -> code |> String.split(" ", parts: 2) |> List.first() end)

        assert HTTP.status_code(group: group, type: :simple) in group_numbers
      end
    end
  end
end
