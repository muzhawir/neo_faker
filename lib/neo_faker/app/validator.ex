defmodule NeoFaker.App.Validator do
  @moduledoc false

  alias NeoFaker.Helpers.Options

  @name_styles [:camel_case, :pascal_case, :dashed, :underscore, :single]
  @semver_types [:pre_release, :build, :pre_release_build]

  @doc """
  Validates the app name style option.

  Accepts `nil` or one of `#{inspect([:camel_case, :pascal_case, :dashed, :underscore, :single])}`.
  Raises `ArgumentError` if the style is not valid.
  """
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

  @doc """
  Validates the app name style specifically for bundle IDs.

  Only accepts `:underscore` or `:dashed`. Raises `ArgumentError` for any other value.
  """
  @spec validate_name_style_for_bundle!(atom()) :: :ok
  def validate_name_style_for_bundle!(style) when style in [:underscore, :dashed], do: :ok

  def validate_name_style_for_bundle!(style) do
    raise ArgumentError,
          "Invalid style for bundle_id. Expected one of [:underscore, :dashed], got: #{inspect(style)}"
  end

  @doc """
  Validates the semantic version type option.

  Accepts `nil` or one of `#{inspect([:pre_release, :build, :pre_release_build])}`.
  Raises `ArgumentError` if the type is not valid.
  """
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
