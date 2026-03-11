defmodule NeoFaker.Address.Generator do
  @moduledoc false

  @spec latitude(non_neg_integer()) :: float()
  def latitude(precision), do: Float.round(:rand.uniform() * 180 - 90, precision)

  @spec longitude(non_neg_integer()) :: float()
  def longitude(precision), do: Float.round(:rand.uniform() * 360 - 180, precision)

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

  @spec validate_precision!(integer()) :: :ok
  def validate_precision!(precision) when is_integer(precision) and precision >= 0, do: :ok

  def validate_precision!(precision) when is_integer(precision) do
    raise ArgumentError, "precision must be non-negative, got: #{precision}"
  end

  def validate_precision!(invalid) do
    raise ArgumentError, "precision must be an integer, got: #{inspect(invalid)}"
  end
end
