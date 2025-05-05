defmodule NeoFaker.HttpTest do
  use ExUnit.Case, async: true

  import NeoFaker.Data.Cache, only: [fetch!: 3]

  alias NeoFaker.Http

  describe "user_agent/0" do
    test "returns a random user agent" do
      assert is_binary(Http.user_agent()) and String.valid?(Http.user_agent())
    end
  end

  describe "request_method/0" do
    test "returns a random request method" do
      assert Http.request_method() in ["GET", "POST", "PUT", "DELETE", "PATCH"]
    end
  end

  describe "referrer_policy/0" do
    test "returns a random referrer policy" do
      referrer_policies = [
        "no-referrer",
        "no-referrer-when-downgrade",
        "same-origin",
        "origin",
        "strict-origin",
        "origin-when-cross-origin",
        "strict-origin-when-cross-origin",
        "unsafe-url"
      ]

      assert Http.referrer_policy() in referrer_policies
    end
  end

  describe "status_code/1" do
    test "returns a random status code" do
      status_code =
        :default
        |> fetch!(NeoFaker.Http, "status_code.exs")
        |> Map.values()
        |> List.flatten()

      assert Http.status_code(type: :detailed) in status_code
    end

    test "returns a simple random status code number" do
      get_number_code = fn code -> code |> String.split(" ", parts: 2) |> List.first() end

      status_code =
        :default
        |> fetch!(NeoFaker.Http, "status_code.exs")
        |> Map.values()
        |> List.flatten()
        |> Enum.map(&get_number_code.(&1))

      assert Http.status_code(type: :simple) in status_code
    end

    test "returns a random status code with specific group" do
      group_status_code = [
        :information,
        :success,
        :redirection,
        :client_error,
        :server_error
      ]

      for group <- group_status_code do
        group_string = Atom.to_string(group)

        status_code =
          :default
          |> fetch!(NeoFaker.Http, "status_code.exs")
          |> Map.get(group_string)

        assert Http.status_code(group: group) in status_code
      end
    end
  end
end
