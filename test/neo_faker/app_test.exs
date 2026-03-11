defmodule NeoFaker.AppTest do
  use ExUnit.Case, async: true

  alias NeoFaker.App

  defp valid_core_version?(version) do
    integer_in_range? = fn part ->
      case Integer.parse(part) do
        {int, ""} when int in 0..30 -> true
        _ -> false
      end
    end

    version
    |> String.split(".")
    |> Enum.all?(integer_in_range?)
  end

  defp valid_pre_release_identifier?(identifier) do
    case String.split(identifier, ".") do
      [label, number] ->
        label in ~w[alpha beta rc] and
          match?({n, ""} when n in 1..10, Integer.parse(number))

      _ ->
        false
    end
  end

  defp valid_build_number?(number) do
    with <<year::binary-size(4), month::binary-size(2), day::binary-size(2)>> <- number,
         {:ok, _} <- Date.from_iso8601("#{year}-#{month}-#{day}") do
      true
    else
      _ -> false
    end
  end

  defp valid_app_name?(opts \\ nil) do
    regex =
      case opts do
        nil -> ~r/^[A-Z][a-z0-9]+ [A-Z][a-z0-9]+$/
        :camel_case -> ~r/^[a-z]+(?:[A-Z][a-z0-9]*)*$/
        :pascal_case -> ~r/^[A-Z][a-z0-9]*(?:[A-Z][a-z0-9]*)*$/
        :dashed -> ~r/^[a-zA-Z]+(?:-[a-zA-Z0-9]+)*$/
        :single -> ~r/^[A-Z]?[a-z0-9]+$/
      end

    Regex.match?(regex, App.name(style: opts))
  end

  defp assert_semver_pre_release do
    [core, pre] = String.split(App.semver(type: :pre_release), "-")

    assert valid_core_version?(core)
    assert valid_pre_release_identifier?(pre)
  end

  defp assert_semver_build do
    [core, build] = String.split(App.semver(type: :build), "+")

    assert valid_core_version?(core)
    assert valid_build_number?(build)
  end

  defp assert_semver_pre_release_build do
    [core, rest] = String.split(App.semver(type: :pre_release_build), "-")
    [pre, build] = String.split(rest, "+")

    assert valid_core_version?(core)
    assert valid_pre_release_identifier?(pre)
    assert valid_build_number?(build)
  end

  describe "author/0" do
    test "returns a valid string for app author" do
      assert String.valid?(App.author())
    end
  end

  describe "description/0" do
    test "returns a valid string for app description" do
      assert String.valid?(App.description())
    end
  end

  describe "license/0" do
    test "returns a valid string for an open source license" do
      assert String.valid?(App.license())
    end
  end

  describe "name/2" do
    test "returns an app name in default format" do
      assert valid_app_name?()
    end

    test "returns an app name for each supported style option" do
      for option <- [:camel_case, :pascal_case, :dashed, :single] do
        assert valid_app_name?(option)
      end
    end
  end

  describe "semver/1" do
    test "returns a valid semantic version number" do
      assert valid_core_version?(App.semver())
    end

    test "returns a semantic version number with pre-release identifier" do
      assert_semver_pre_release()
    end

    test "returns a semantic version number with build metadata" do
      assert_semver_build()
    end

    test "returns a semantic version number with pre-release identifier and build metadata" do
      assert_semver_pre_release_build()
    end
  end

  describe "version/0" do
    test "returns a valid version number" do
      assert valid_core_version?(App.version())
    end
  end
end
