defmodule NeoFaker.HTTPTest do
  use ExUnit.Case, async: true

  alias NeoFaker.Data
  alias NeoFaker.HTTP
  alias NeoFaker.HTTP.HeaderGenerator
  alias NeoFaker.HTTP.UserAgentGenerator

  @all_groups [:information, :success, :redirection, :client_error, :server_error]
  @common_methods ["GET", "POST", "PUT", "DELETE", "PATCH", "QUERY"]
  @all_methods [
    "GET",
    "POST",
    "PUT",
    "DELETE",
    "PATCH",
    "HEAD",
    "OPTIONS",
    "TRACE",
    "CONNECT",
    "QUERY"
  ]
  @referrer_policies [
    "no-referrer",
    "no-referrer-when-downgrade",
    "same-origin",
    "origin",
    "strict-origin",
    "origin-when-cross-origin",
    "strict-origin-when-cross-origin",
    "unsafe-url"
  ]
  @request_headers ~w(Accept Accept-Encoding Accept-Language Authorization Cache-Control
                      Connection Cookie Host Referer User-Agent)
  @response_headers [
    "Access-Control-Allow-Origin",
    "Content-Encoding",
    "Content-Length",
    "Content-Type",
    "Date",
    "ETag",
    "Expires",
    "Last-Modified",
    "Server",
    "Set-Cookie"
  ]

  defp fetch_status_codes, do: Data.fetch!(:default, HTTP, "status_code.exs")
  defp all_status_codes, do: fetch_status_codes() |> Map.values() |> List.flatten()

  defp status_code_numbers do
    Enum.map(all_status_codes(), fn code ->
      code |> String.split(" ", parts: 2) |> List.first()
    end)
  end

  defp status_codes_for_group(group), do: Map.get(fetch_status_codes(), Atom.to_string(group))

  defp user_agents(key) do
    :default |> Data.fetch!(HTTP, "user_agent.exs") |> Map.fetch!(key)
  end

  defp all_user_agents do
    :default |> Data.fetch!(HTTP, "user_agent.exs") |> Map.values() |> List.flatten()
  end

  describe "user_agent/1" do
    test "returns a non-empty string by default" do
      result = HTTP.user_agent()

      assert is_binary(result) and String.valid?(result)
      refute result == ""
    end

    test "returns a browser user-agent when type: :browser" do
      assert HTTP.user_agent(type: :browser) in user_agents("browsers")
    end

    test "returns a crawler bot token when type: :crawler" do
      assert HTTP.user_agent(type: :crawler) in user_agents("crawlers")
    end

    test "returns an AI bot token when type: :ai" do
      assert HTTP.user_agent(type: :ai) in user_agents("ai")
    end

    test "type: :all draws from every category" do
      assert HTTP.user_agent(type: :all) in all_user_agents()
    end

    test "raises NimbleOptions.ValidationError for an unknown type" do
      assert_raise NimbleOptions.ValidationError, fn -> HTTP.user_agent(type: :bot) end
    end
  end

  describe "request_method/1" do
    test "returns a common method by default" do
      assert HTTP.request_method() in @common_methods
    end

    test "returns any of the ten standard methods when common_only: false" do
      for _ <- 1..200, do: assert(HTTP.request_method(common_only: false) in @all_methods)
    end

    test "never returns an uncommon method by default" do
      for _ <- 1..200 do
        refute HTTP.request_method() in ["HEAD", "OPTIONS", "TRACE", "CONNECT"]
      end
    end
  end

  describe "referrer_policy/0" do
    test "returns a valid referrer policy string" do
      assert HTTP.referrer_policy() in @referrer_policies
    end
  end

  describe "status_code/1" do
    test "returns a detailed status code string by default group" do
      assert HTTP.status_code(type: :detailed) in all_status_codes()
    end

    test "returns a simple numeric status code string" do
      assert HTTP.status_code(type: :simple) in status_code_numbers()
      assert HTTP.status_code() in status_code_numbers()
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

    test "raises NimbleOptions.ValidationError for an unknown group" do
      assert_raise NimbleOptions.ValidationError, fn -> HTTP.status_code(group: :teapot) end
    end
  end

  describe "protocol_version/1" do
    test "returns one of HTTP/1.0, HTTP/1.1, HTTP/2, HTTP/3 by default" do
      for _ <- 1..100 do
        assert HTTP.protocol_version() in ["HTTP/1.0", "HTTP/1.1", "HTTP/2", "HTTP/3"]
      end
    end

    test "excludes HTTP/3 when include_http3: false" do
      for _ <- 1..100 do
        assert HTTP.protocol_version(include_http3: false) in ["HTTP/1.0", "HTTP/1.1", "HTTP/2"]
      end
    end
  end

  describe "header_name/1" do
    test "returns a header from both categories by default" do
      assert HTTP.header_name() in (@request_headers ++ @response_headers)
    end

    test "returns a request header when type: :request" do
      assert HTTP.header_name(type: :request) in @request_headers
    end

    test "returns a response header when type: :response" do
      assert HTTP.header_name(type: :response) in @response_headers
    end

    test "raises NimbleOptions.ValidationError for an unknown type" do
      assert_raise NimbleOptions.ValidationError, fn -> HTTP.header_name(type: :trailer) end
    end
  end

  describe "all_request_methods/0" do
    test "returns every standard HTTP method" do
      assert HTTP.all_request_methods() == @all_methods
    end
  end

  describe "all_referrer_policies/0" do
    test "returns every standard referrer policy" do
      assert HTTP.all_referrer_policies() == @referrer_policies
    end
  end

  describe "HeaderGenerator.name/1" do
    test "draws from the right list for each category" do
      assert HeaderGenerator.name(:request) in @request_headers
      assert HeaderGenerator.name(:response) in @response_headers
      assert HeaderGenerator.name(:all) in (@request_headers ++ @response_headers)
    end
  end

  describe "UserAgentGenerator.name/1" do
    test "returns a value for each type" do
      assert UserAgentGenerator.name(:browser) in user_agents("browsers")
      assert UserAgentGenerator.name(:crawler) in user_agents("crawlers")
      assert UserAgentGenerator.name(:ai) in user_agents("ai")
      assert UserAgentGenerator.name(:all) in all_user_agents()
    end
  end
end
