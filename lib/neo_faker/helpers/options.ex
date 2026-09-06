defmodule NeoFaker.Helpers.Options do
  @moduledoc false
  @moduledoc since: "0.14.0"

  @doc """
  Validates `opts` against a `NimbleOptions` schema.

  Returns the validated keyword list with defaults applied. Raises `ArgumentError` — not
  `NimbleOptions.ValidationError` — so every domain function keeps its documented "Raises
  ArgumentError" contract regardless of how its options happen to be validated internally.

  ## Examples

      iex> schema = NimbleOptions.new!(format: [type: {:in, [:struct, :iso8601]}, default: :struct])
      iex> NeoFaker.Helpers.Options.validate!([], schema)
      [format: :struct]

      iex> schema = NimbleOptions.new!(format: [type: {:in, [:struct, :iso8601]}, default: :struct])
      iex> NeoFaker.Helpers.Options.validate!([format: :bogus], schema)
      ** (ArgumentError) invalid value for :format option: expected one of [:struct, :iso8601], got: :bogus

  """
  @spec validate!(keyword(), NimbleOptions.t()) :: keyword()
  def validate!(opts, schema) do
    case NimbleOptions.validate(opts, schema) do
      {:ok, validated} -> validated
      {:error, %NimbleOptions.ValidationError{message: message}} -> raise ArgumentError, message
    end
  end
end
