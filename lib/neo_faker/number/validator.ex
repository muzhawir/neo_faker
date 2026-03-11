defmodule NeoFaker.Number.Validator do
  @moduledoc false

  @doc """
  Validates that the given value is a `Range` with `first <= last`.

  Raises `ArgumentError` if the value is not a `Range`, or if the range is descending.
  The `name` parameter is used in the error message to identify which argument is invalid.
  """
  @spec validate_range!(Range.t(), String.t()) :: :ok
  def validate_range!(range, name) when is_struct(range, Range) do
    if range.first <= range.last do
      :ok
    else
      raise ArgumentError,
            "#{name} range must have first <= last, got: #{range.first}..#{range.last}"
    end
  end

  def validate_range!(invalid, name) do
    raise ArgumentError, "#{name} must be a Range, got: #{inspect(invalid)}"
  end
end
