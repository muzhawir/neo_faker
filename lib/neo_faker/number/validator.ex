defmodule NeoFaker.Number.Validator do
  @moduledoc false

  alias NeoFaker.Helpers.Validator

  @doc """
  Returns `range` if it is a non-empty range of non-negative integers, raising
  `ArgumentError` otherwise.

  The fractional digits of `NeoFaker.Number.float/2` are written after the
  decimal point as-is, so a negative value would produce `"1.-5"`.
  """
  @spec validate_fraction_range!(term()) :: Range.t()
  def validate_fraction_range!(range) do
    range = Validator.validate_range!(range, "right_digit")

    if range_min(range) >= 0 do
      range
    else
      raise ArgumentError,
            "right_digit must only contain non-negative integers, got: #{inspect(range)}"
    end
  end

  # The smallest element of a non-empty range, in constant time.
  defp range_min(%Range{first: first, step: step}) when step > 0, do: first

  defp range_min(%Range{first: first, step: step} = range),
    do: first + (Range.size(range) - 1) * step

  @doc """
  Returns `:ok` if `precision` is an integer from `0` to `15`, the range
  `Float.round/2` supports, raising `ArgumentError` otherwise.
  """
  @spec validate_precision!(term()) :: :ok
  def validate_precision!(precision) when precision in 0..15, do: :ok

  def validate_precision!(precision) do
    raise ArgumentError,
          "precision must be an integer between 0 and 15, got: #{inspect(precision)}"
  end
end
