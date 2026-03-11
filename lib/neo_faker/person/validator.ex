defmodule NeoFaker.Person.Validator do
  @moduledoc false

  alias NeoFaker.Helpers.Options

  @sex [:unisex, :male, :female]

  @spec validate_sex!(atom()) :: :ok
  def validate_sex!(sex) do
    case Options.validate_enum(:sex, sex, @sex) do
      :ok -> :ok
      {:error, reason} -> raise ArgumentError, reason
    end
  end

  @spec validate_age_range!(non_neg_integer(), non_neg_integer()) :: :ok
  def validate_age_range!(min, max) when is_integer(min) and is_integer(max) do
    cond do
      min < 0 ->
        raise ArgumentError, "min must be non-negative, got: #{min}"

      max < 0 ->
        raise ArgumentError, "max must be non-negative, got: #{max}"

      min > max ->
        raise ArgumentError, "min must be less than or equal to max"

      true ->
        :ok
    end
  end

  def validate_age_range!(min, _max) when not is_integer(min) do
    raise ArgumentError, "min must be an integer, got: #{inspect(min)}"
  end

  def validate_age_range!(_min, max) when not is_integer(max) do
    raise ArgumentError, "max must be an integer, got: #{inspect(max)}"
  end
end
