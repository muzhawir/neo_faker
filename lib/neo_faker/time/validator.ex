defmodule NeoFaker.Time.Validator do
  @moduledoc false

  @doc """
  Validates that the given value is a `Range` with `first <= last`.

  Returns `:ok` if valid. Raises `ArgumentError` if the range is inverted or if the value is
  not a `Range`.
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
  Validates that `start` is before or equal to `finish`.

  Returns `:ok` if valid. Raises `ArgumentError` if `start` is after `finish`.
  """
  @spec validate_time_order!(Time.t(), Time.t()) :: :ok
  def validate_time_order!(start, finish) do
    case Time.compare(start, finish) do
      :gt ->
        raise ArgumentError, "start time must be before or equal to finish time"

      _ ->
        :ok
    end
  end
end
