defmodule NeoFaker.Time.Validator do
  @moduledoc false

  alias NeoFaker.Helpers.Options

  @datetime_formats [:struct, :iso8601]
  @time_units [:hour, :minute, :second]

  @doc """
  Retrieves and validates the `:format` option from the given keyword list.

  Returns the format atom (`:struct` or `:iso8601`), defaulting to `:struct` if not provided.
  Raises `ArgumentError` if the value is not a valid format.
  """
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

  @doc """
  Retrieves and validates the `:unit` option from the given keyword list.

  Returns the unit atom (`:hour`, `:minute`, or `:second`), defaulting to `:hour` if not
  provided. Raises `ArgumentError` if the value is not a valid time unit.
  """
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
