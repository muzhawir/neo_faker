defmodule NeoFaker.Boolean do
  @moduledoc """
  Functions for generating random boolean values.

  Provides utilities to generate `true` or `false` with a configurable probability,
  with an option to return integer equivalents instead.
  """
  @moduledoc since: "0.5.0"

  alias NeoFaker.Boolean.Generator
  alias NeoFaker.Helpers.Formatter
  alias NeoFaker.Helpers.Options

  @ratio_range 0..100

  @options_schema NimbleOptions.new!(integer: [type: :boolean, default: false])

  @doc """
  Generates a random boolean value with a configurable probability of returning `true`.

  The `true_ratio` parameter sets the percentage chance (0–100) of returning `true`.
  Defaults to `50`.

  ## Options

    * `:integer` (boolean) - when `true`, returns `1` or `0` instead of `true` or `false`.
      Defaults to `false`.

  ## Examples

      iex> NeoFaker.Boolean.boolean()
      false

      iex> NeoFaker.Boolean.boolean(75)
      true

      iex> NeoFaker.Boolean.boolean(75, integer: true)
      1

      iex> NeoFaker.Boolean.boolean(0)
      false

      iex> NeoFaker.Boolean.boolean(100)
      true

  """
  @spec boolean(0..100, keyword()) :: boolean() | non_neg_integer()
  def boolean(true_ratio \\ 50, opts \\ [])

  def boolean(true_ratio, opts) when true_ratio in @ratio_range do
    opts = Options.validate!(opts, @options_schema)
    result = Generator.boolean(true_ratio)

    if Keyword.fetch!(opts, :integer) do
      Formatter.format_boolean(result, :integer)
    else
      result
    end
  end

  def boolean(true_ratio, _opts) do
    raise ArgumentError, "true_ratio must be between 0 and 100, got: #{true_ratio}"
  end
end
