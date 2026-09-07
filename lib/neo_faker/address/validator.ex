defmodule NeoFaker.Address.Validator do
  @moduledoc false

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
