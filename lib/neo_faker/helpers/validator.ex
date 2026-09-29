defmodule NeoFaker.Helpers.Validator do
  @moduledoc false

  # Argument checks shared by several domains. Domain-specific rules live in
  # the domain's own `Validator` module.

  @doc """
  Returns `range` if it is a non-empty `Range`, raising `ArgumentError` otherwise.

  Emptiness is checked with `Range.size/1` rather than `first <= last`, so a
  descending range with a negative step (`10..1//-1`) is accepted, while an
  ascending bound pair with a negative step (`1..10//-1`, which contains no
  integers) is rejected before `Enum.random/1` raises `Enum.EmptyError`.
  `name` identifies the argument in the error message.
  """
  @spec validate_range!(term(), String.t()) :: Range.t()
  def validate_range!(%Range{} = range, name) do
    if Range.size(range) > 0 do
      range
    else
      raise ArgumentError, "#{name} must be a non-empty range, got: #{inspect(range)}"
    end
  end

  def validate_range!(other, name) do
    raise ArgumentError, "#{name} must be a range, got: #{inspect(other)}"
  end

  @doc """
  NimbleOptions `{:custom, ...}` validator for an option that takes a non-empty range.
  """
  @spec validate_range_option(term()) :: {:ok, Range.t()} | {:error, String.t()}
  def validate_range_option(%Range{} = range) do
    if Range.size(range) > 0 do
      {:ok, range}
    else
      {:error, "expected a non-empty range, got: #{inspect(range)}"}
    end
  end

  def validate_range_option(other), do: {:error, "expected a range, got: #{inspect(other)}"}

  @doc """
  Returns `:ok` if `min` and `max` are non-negative integers with `min <= max`.

  Raises `ArgumentError` otherwise. `names` is the `{min_name, max_name}` pair
  used in error messages.
  """
  @spec validate_non_neg_bounds!(term(), term(), {String.t(), String.t()}) :: :ok
  def validate_non_neg_bounds!(min, max, {min_name, max_name}) do
    cond do
      not is_integer(min) or min < 0 ->
        raise ArgumentError, "#{min_name} must be a non-negative integer, got: #{inspect(min)}"

      not is_integer(max) or max < 0 ->
        raise ArgumentError, "#{max_name} must be a non-negative integer, got: #{inspect(max)}"

      min > max ->
        raise ArgumentError,
              "#{min_name} must be less than or equal to #{max_name}, " <>
                "got: #{min_name}=#{min}, #{max_name}=#{max}"

      true ->
        :ok
    end
  end
end
