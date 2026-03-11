defmodule NeoFaker.App.Validator do
  @moduledoc false

  alias NeoFaker.Helpers.Options

  @name_styles [:camel_case, :pascal_case, :dashed, :underscore, :single]
  @semver_types [:pre_release, :build, :pre_release_build]

  @spec validate_name_style!(atom() | nil) :: :ok
  def validate_name_style!(nil), do: :ok

  def validate_name_style!(style) do
    valid_styles = [nil | @name_styles]

    case Options.validate_enum(:style, style, valid_styles) do
      :ok ->
        :ok

      {:error, reason} ->
        raise ArgumentError, reason
    end
  end

  @spec validate_name_style_for_bundle!(atom()) :: :ok
  def validate_name_style_for_bundle!(style) when style in [:underscore, :dashed], do: :ok

  def validate_name_style_for_bundle!(style) do
    raise ArgumentError,
          "Invalid style for bundle_id. Expected one of [:underscore, :dashed], got: #{inspect(style)}"
  end

  @spec validate_semver_type!(atom() | nil) :: :ok
  def validate_semver_type!(nil), do: :ok

  def validate_semver_type!(type) do
    valid_types = [nil | @semver_types]

    case Options.validate_enum(:type, type, valid_types) do
      :ok ->
        :ok

      {:error, reason} ->
        raise ArgumentError, reason
    end
  end
end
