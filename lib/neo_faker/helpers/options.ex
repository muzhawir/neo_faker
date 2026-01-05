defmodule NeoFaker.Helpers.Options do
  @moduledoc """
  Provides utilities for standardized option handling across NeoFaker modules.

  This module centralizes common patterns for extracting and validating options
  from keyword lists, reducing code duplication and ensuring consistent behavior.
  """
  @moduledoc since: "0.14.0"

  @doc """
  Gets a value from a keyword list with a default fallback.

  This is a convenience wrapper around `Keyword.get/3` for consistency.

  ## Examples

      iex> NeoFaker.Helpers.Options.get([foo: :bar], :foo, :default)
      :bar

      iex> NeoFaker.Helpers.Options.get([], :missing, :default)
      :default

  """
  @spec get(keyword(), atom(), any()) :: any()
  def get(opts, key, default) when is_list(opts) and is_atom(key) do
    Keyword.get(opts, key, default)
  end

  @doc """
  Gets multiple values from a keyword list using a schema.

  The schema is a keyword list where keys are the option names and values are
  the default values to use if the option is not present.

  ## Examples

      iex> schema = [format: :struct, locale: :default, count: 1]
      iex> NeoFaker.Helpers.Options.get_many([format: :iso8601], schema)
      %{format: :iso8601, locale: :default, count: 1}

  """
  @spec get_many(keyword(), keyword()) :: map()
  def get_many(opts, schema) when is_list(opts) and is_list(schema) do
    Map.new(schema, fn {key, default} ->
      {key, Keyword.get(opts, key, default)}
    end)
  end

  @doc """
  Validates that an option value is one of the allowed values.

  Returns `:ok` if valid, or `{:error, reason}` if invalid.

  ## Examples

      iex> NeoFaker.Helpers.Options.validate_enum(:format, :struct, [:struct, :iso8601])
      :ok

      iex> NeoFaker.Helpers.Options.validate_enum(:format, :invalid, [:struct, :iso8601])
      {:error, "Invalid value for :format. Expected one of [:struct, :iso8601], got: :invalid"}

  """
  @spec validate_enum(atom(), any(), list()) :: :ok | {:error, String.t()}
  def validate_enum(key, value, allowed_values) when is_atom(key) and is_list(allowed_values) do
    if value in allowed_values do
      :ok
    else
      {:error,
       "Invalid value for :#{key}. Expected one of #{inspect(allowed_values)}, got: #{inspect(value)}"}
    end
  end

  @doc """
  Validates that an option value is within a specified range.

  Returns `:ok` if valid, or `{:error, reason}` if invalid.

  ## Examples

      iex> NeoFaker.Helpers.Options.validate_range(:ratio, 50, 0..100)
      :ok

      iex> NeoFaker.Helpers.Options.validate_range(:ratio, 150, 0..100)
      {:error, "Value for :ratio must be between 0 and 100, got: 150"}

  """
  @spec validate_range(atom(), number(), Range.t()) :: :ok | {:error, String.t()}
  def validate_range(key, value, range) when is_atom(key) do
    if value in range do
      :ok
    else
      {:error,
       "Value for :#{key} must be between #{range.first} and #{range.last}, got: #{value}"}
    end
  end

  @doc """
  Validates multiple options against a validation schema.

  The schema is a map where keys are option names and values are validation functions
  that return `:ok` or `{:error, reason}`.

  Returns `:ok` if all validations pass, or `{:error, reason}` for the first failure.

  ## Examples

      iex> validations = %{
      ...>   format: fn v -> NeoFaker.Helpers.Options.validate_enum(:format, v, [:struct, :iso8601]) end
      ...> }
      iex> NeoFaker.Helpers.Options.validate_many([format: :struct], validations)
      :ok

  """
  @spec validate_many(keyword(), map()) :: :ok | {:error, String.t()}
  def validate_many(opts, validations) when is_list(opts) and is_map(validations) do
    for {key, validator} <- validations do
      case Keyword.fetch(opts, key) do
        {:ok, value} ->
          result = validator.(value)
          if result != :ok, do: throw(result)

        :error ->
          :ok
      end
    end

    :ok
  catch
    {:error, reason} -> {:error, reason}
    error -> error
  end

  @doc """
  Gets and validates an option value.

  Combines `get/3` and validation in a single call. If validation fails,
  raises an `ArgumentError`.

  ## Examples

      iex> NeoFaker.Helpers.Options.get_and_validate(
      ...>   [format: :struct],
      ...>   :format,
      ...>   :struct,
      ...>   &NeoFaker.Helpers.Options.validate_enum(:format, &1, [:struct, :iso8601])
      ...> )
      :struct

  """
  @spec get_and_validate(keyword(), atom(), any(), (any() -> :ok | {:error, String.t()})) :: any()
  def get_and_validate(opts, key, default, validator)
      when is_list(opts) and is_atom(key) and is_function(validator, 1) do
    value = get(opts, key, default)

    case validator.(value) do
      :ok -> value
      {:error, reason} -> raise ArgumentError, reason
    end
  end
end
