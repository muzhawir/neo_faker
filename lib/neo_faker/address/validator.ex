defmodule NeoFaker.Address.Validator do
  @moduledoc false

  @building_number_types [:string, :integer]
  @coordinate_types [:full, :latitude, :longitude]

  @doc """
  Validates the `:type` option for `building_number/2`.

  Raises `ArgumentError` if the type is not one of `#{inspect([:string, :integer])}`.
  """
  @spec validate_building_number_type!(atom()) :: :ok
  def validate_building_number_type!(type) when type in @building_number_types, do: :ok

  def validate_building_number_type!(other) do
    raise ArgumentError,
          "invalid :type for building_number/2. " <>
            "Expected one of #{inspect(@building_number_types)}, got: #{inspect(other)}"
  end

  @doc """
  Validates the `:type` option for `coordinate/1`.

  Raises `ArgumentError` if the type is not one of `#{inspect([:full, :latitude, :longitude])}`.
  """
  @spec validate_coordinate_type!(atom()) :: :ok
  def validate_coordinate_type!(type) when type in @coordinate_types, do: :ok

  def validate_coordinate_type!(other) do
    raise ArgumentError,
          "invalid :type for coordinate/1. " <>
            "Expected one of #{inspect(@coordinate_types)}, got: #{inspect(other)}"
  end

  @doc """
  Validates that the given value is a `Range` with `first <= last`.

  Raises `ArgumentError` if the value is not a `Range`, or if the range is descending.
  """
  @spec validate_range!(Range.t()) :: :ok
  def validate_range!(range) when is_struct(range, Range) do
    if range.first <= range.last do
      :ok
    else
      raise ArgumentError, "Invalid range: first must be less than or equal to last"
    end
  end

  def validate_range!(invalid) do
    raise ArgumentError, "Expected a Range, got: #{inspect(invalid)}"
  end

  @doc """
  Validates that the given precision is a non-negative integer.

  Raises `ArgumentError` if `precision` is a negative integer or not an integer at all.
  """
  @spec validate_precision!(integer()) :: :ok
  def validate_precision!(precision) when is_integer(precision) and precision >= 0, do: :ok

  def validate_precision!(precision) when is_integer(precision) do
    raise ArgumentError, "precision must be non-negative, got: #{precision}"
  end

  def validate_precision!(invalid) do
    raise ArgumentError, "precision must be an integer, got: #{inspect(invalid)}"
  end
end
