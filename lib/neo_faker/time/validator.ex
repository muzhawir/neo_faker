defmodule NeoFaker.Time.Validator do
  @moduledoc false

  alias NeoFaker.Helpers.Options

  @datetime_formats [:struct, :iso8601]
  @time_units [:hour, :minute, :second]

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

  @spec get_and_validate_unit!(Keyword.t()) :: atom()
  def get_and_validate_unit!(opts) do
    unit = Options.get(opts, :unit, :hour)

    case Options.validate_enum(:unit, unit, @time_units) do
      :ok ->
        unit

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
