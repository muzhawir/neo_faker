defmodule NeoFaker.Address.Validator do
  @moduledoc false

  @building_number_types [:string, :integer]
  @coordinate_types [:full, :latitude, :longitude]

  @doc """
  Validates the `:type` option for `building_number/2`.

  Returns `{:ok, type}` if valid, `{:error, message}` otherwise. Used as a `NimbleOptions`
  custom validator.
  """
  @spec validate_building_number_type(term()) :: {:ok, atom()} | {:error, String.t()}
  def validate_building_number_type(type) when type in @building_number_types, do: {:ok, type}

  def validate_building_number_type(other) do
    {:error,
     "invalid :type for building_number/2. " <>
       "Expected one of #{inspect(@building_number_types)}, got: #{inspect(other)}"}
  end

  @doc """
  Validates the `:type` option for `coordinate/1`.

  Returns `{:ok, type}` if valid, `{:error, message}` otherwise. Used as a `NimbleOptions`
  custom validator.
  """
  @spec validate_coordinate_type(term()) :: {:ok, atom()} | {:error, String.t()}
  def validate_coordinate_type(type) when type in @coordinate_types, do: {:ok, type}

  def validate_coordinate_type(other) do
    {:error,
     "invalid :type for coordinate/1. " <>
       "Expected one of #{inspect(@coordinate_types)}, got: #{inspect(other)}"}
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
end
