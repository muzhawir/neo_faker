defmodule Nf.AppTest do
  use ExUnit.Case, async: true

  alias Nf.App

  # Helper function for validate core version
  @spec validate_version_core(String.t()) :: boolean
  defp validate_version_core(version) do
    version
    |> String.split(".")
    |> Enum.map(&String.to_integer/1)
    |> Enum.map(&(&1 in 0..30))
    |> Enum.all?()
  end

  # Helper function for validate pre-release identifier
  defp validate_pre_release_identifier(identifier) do
    [label, number] = String.split(identifier, ".")
    valid_label? = label in ~w[alpha beta rc]
    valid_number? = String.to_integer(number) in 1..10

    valid_label? and valid_number?
  end

  # Helper function for validate build number
  defp validate_build_number(number) do
    build_date =
      number
      |> String.split_at(4)
      |> then(fn {year, rest} -> {year, String.split_at(rest, 2)} end)
      |> then(fn {year, {month, day}} -> "#{year}-#{month}-#{day}" end)

    case Date.from_iso8601(build_date) do
      {:ok, _} -> true
      :error -> false
    end
  end

  # Helper function for validate name function with options
  @spec validate_name_app(atom()) :: boolean
  defp validate_name_app(amount \\ 1, opts \\ nil) do
    regexp =
      case opts do
        nil -> ~r/^[A-Z][a-z0-9]+ [A-Z][a-z0-9]+$/
        :camel_case -> ~r/^[a-z]+(?:[A-Z][a-z0-9]*)*$/
        :pascal_case -> ~r/^[A-Z][a-z0-9]*(?:[A-Z][a-z0-9]*)*$/
        :dashed -> ~r/^[a-zA-Z]+(?:-[a-zA-Z0-9]+)*$/
        :single -> ~r/^[A-Z]?[a-z0-9]+$/
      end

    app_name = App.name(amount, style: opts)

    Regex.match?(regexp, app_name)
  end

  describe "author/0" do
    test "returns a full name of an app author" do
      author_name = App.author()

      assert String.valid?(author_name)
    end
  end

  describe "name/2" do
    test "returns an app name" do
      assert validate_name_app()
    end

    test "returns an app name with custom amount" do
      assert is_list(App.name(2))
    end

    test "returns an app name with :camel_case option" do
      assert validate_name_app(1, :camel_case)
    end

    test "returns an app name with :pascal_case option" do
      assert validate_name_app(1, :pascal_case)
    end

    test "returns an app name with :dashed option" do
      assert validate_name_app(1, :dashed)
    end

    test "returns an app name with :single option" do
      assert validate_name_app(1, :single)
    end
  end

  describe "description/0" do
    test "returns a short app description" do
      description = App.description()

      assert String.valid?(description)
    end

    test "returns a short app description with custom amount" do
      assert is_list(App.description(2))
    end
  end

  describe "semver/1" do
    test "returns a semantic version number" do
      assert validate_version_core(App.semver())
    end

    test "returns a semantic version number with pre-release type" do
      semver = App.semver(type: :pre_release)
      [core_version, pre_release_identifier] = String.split(semver, "-")
      is_valid_core_version? = validate_version_core(core_version)
      is_valid_pre_release_identifier? = validate_pre_release_identifier(pre_release_identifier)

      assert is_valid_core_version? and is_valid_pre_release_identifier?
    end

    test "returns a semantic version number with build number type" do
      semver = App.semver(type: :build)
      [core_version, build_number] = String.split(semver, "+")
      is_valid_core_version? = validate_version_core(core_version)
      id_valid_build_number? = validate_build_number(build_number)

      assert is_valid_core_version? and id_valid_build_number?
    end

    test "returns a semantic version number with pre-release and build number type" do
      semver = App.semver(type: :pre_release_build)

      [core_version, pre_release, build_number] =
        semver
        |> String.split("-")
        |> then(fn [core, rest] -> [core, String.split(rest, "+")] end)
        |> then(fn [core, [pre_release, build_number]] -> [core, pre_release, build_number] end)

      is_valid_core_version? = validate_version_core(core_version)
      is_valid_pre_release_identifier? = validate_pre_release_identifier(pre_release)
      id_valid_build_number? = validate_build_number(build_number)

      assert Enum.all?([is_valid_core_version?, is_valid_pre_release_identifier?, id_valid_build_number?])
    end
  end

  describe "license/0" do
    test "returns an open source license" do
      lisense = App.license()

      assert String.valid?(lisense)
    end

    test "returns an open source license with custom amount" do
      assert is_list(App.license(2))
    end
  end
end
