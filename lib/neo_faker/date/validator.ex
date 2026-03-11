defmodule NeoFaker.Date.Validator do
  @moduledoc false

  alias NeoFaker.Helpers.Options

  @datetime_formats [:struct, :iso8601]

  @spec get_and_validate_format!(Keyword.t()) :: atom()
  def get_and_validate_format!(opts) do
    format = Options.get(opts, :format, :struct)

    case Options.validate_enum(:format, format, @datetime_formats) do
      :ok ->
        format

      {:error, reason} ->
        raise ArgumentError, reason
    end
  end

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

  @spec validate_date_order!(Date.t(), Date.t()) :: :ok
  def validate_date_order!(start, finish) do
    case Date.compare(start, finish) do
      :gt ->
        raise ArgumentError, "start date must be before or equal to finish date"

      _ ->
        :ok
    end
  end

  @spec validate_age_range!(non_neg_integer(), non_neg_integer()) :: :ok
  def validate_age_range!(min_age, max_age) when is_integer(min_age) and is_integer(max_age) do
    cond do
      min_age < 0 ->
        raise ArgumentError, "min_age must be non-negative, got: #{min_age}"

      max_age < 0 ->
        raise ArgumentError, "max_age must be non-negative, got: #{max_age}"

      min_age > max_age ->
        raise ArgumentError, "min_age must be less than or equal to max_age"

      true ->
        :ok
    end
  end

  def validate_age_range!(min_age, _max_age) when not is_integer(min_age) do
    raise ArgumentError, "min_age must be an integer, got: #{inspect(min_age)}"
  end

  def validate_age_range!(_min_age, max_age) when not is_integer(max_age) do
    raise ArgumentError, "max_age must be an integer, got: #{inspect(max_age)}"
  end
end
