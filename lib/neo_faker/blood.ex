defmodule NeoFaker.Blood do
  @moduledoc """
  Functions for generating blood types.

  Provides utilities to generate random blood groups, blood types, and Rh factors following the
  ABO and Rh blood group system classification.
  """
  @moduledoc since: "0.3.1"

  alias NeoFaker.Blood.Generator
  alias NeoFaker.Helpers.Options

  @group_schema NimbleOptions.new!(
                  format: [type: {:in, [:group, :type_only, :rh_only]}, default: :group]
                )

  @medical_notation_schema NimbleOptions.new!(verbose: [type: :boolean, default: false])

  @doc """
  Generates a random blood group.

  Combines a blood type (`A`, `B`, `AB`, or `O`) with an Rh factor (`+` or `-`).

  ## Options

    * `:format` (`:group`, `:type_only`, or `:rh_only`) - which part of the blood group to
      return. Defaults to `:group`.

  ## Examples

      iex> NeoFaker.Blood.group()
      "B+"

      iex> NeoFaker.Blood.group(format: :type_only)
      "O"

      iex> NeoFaker.Blood.group(format: :rh_only)
      "-"

  """
  @spec group(keyword()) :: String.t()
  def group(opts \\ []) do
    format = opts |> Options.validate!(@group_schema) |> Keyword.fetch!(:format)

    case format do
      :group -> "#{type()}#{rh_factor()}"
      :type_only -> type()
      :rh_only -> rh_factor()
    end
  end

  @doc """
  Generates a random blood type.

  Returns one of the four ABO blood types: `"A"`, `"B"`, `"AB"`, or `"O"`.

  ## Examples

      iex> NeoFaker.Blood.type()
      "B"

  """
  @spec type() :: String.t()
  def type, do: Generator.type()

  @doc """
  Generates a random Rh factor.

  Returns either `"+"` (positive) or `"-"` (negative).

  ## Examples

      iex> NeoFaker.Blood.rh_factor()
      "+"

  """
  @spec rh_factor() :: String.t()
  def rh_factor, do: Generator.rh_factor()

  @doc """
  Generates a random blood type in medical notation.

  Returns a descriptive string combining the ABO type and Rh factor.

  ## Options

    * `:verbose` (boolean) - when `true`, uses the full descriptive `"Type X, Rh Y"` form
      instead of `"X Y"`. Defaults to `false`.

  ## Examples

      iex> NeoFaker.Blood.medical_notation()
      "B positive"

      iex> NeoFaker.Blood.medical_notation(verbose: true)
      "Type AB, Rh positive"

  """
  @spec medical_notation(keyword()) :: String.t()
  def medical_notation(opts \\ []) do
    verbose = opts |> Options.validate!(@medical_notation_schema) |> Keyword.fetch!(:verbose)

    blood_type = type()
    rh_text = if rh_factor() == "+", do: "positive", else: "negative"

    if verbose do
      "Type #{blood_type}, Rh #{rh_text}"
    else
      "#{blood_type} #{rh_text}"
    end
  end

  @doc """
  Returns all 4 blood types in the ABO system.

  ## Examples

      iex> NeoFaker.Blood.all_types()
      ["A", "B", "AB", "O"]

  """
  @spec all_types() :: [String.t()]
  def all_types, do: Generator.all_types()

  @doc """
  Returns both possible Rh factors.

  ## Examples

      iex> NeoFaker.Blood.all_rh_factors()
      ["+", "-"]

  """
  @spec all_rh_factors() :: [String.t()]
  def all_rh_factors, do: Generator.all_rh_factors()
end
