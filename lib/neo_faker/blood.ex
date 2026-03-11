defmodule NeoFaker.Blood do
  @moduledoc """
  Functions for generating blood types.

  Provides utilities to generate random blood groups, blood types, and Rh factors
  following the ABO and Rh blood group system classification.
  """
  @moduledoc since: "0.3.1"

  alias NeoFaker.Blood.Validator
  alias NeoFaker.Helpers.Options

  @blood_types ~w[A B AB O]
  @rh_factors ~w[+ -]

  @doc """
  Generates a random blood group.

  Combines a blood type (`A`, `B`, `AB`, or `O`) with an Rh factor (`+` or `-`).
  Use the `:format` option to return only part of the result.

  ## Options

  - `:format` - Controls what is returned. Defaults to `:group`.
    - `:group` - Full blood group, e.g. `"B+"` (default).
    - `:type_only` - Blood type only, e.g. `"B"`.
    - `:rh_only` - Rh factor only, e.g. `"+"`.

  ## Examples

      iex> NeoFaker.Blood.group()
      "B+"

      iex> NeoFaker.Blood.group(format: :type_only)
      "O"

      iex> NeoFaker.Blood.group(format: :rh_only)
      "-"

  """
  @spec group(Keyword.t()) :: String.t()
  def group(opts \\ []) do
    format = Options.get(opts, :format, :group)

    Validator.validate_format!(format)

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
  def type, do: Enum.random(@blood_types)

  @doc """
  Generates a random Rh factor.

  Returns either `"+"` (positive) or `"-"` (negative).

  ## Examples

      iex> NeoFaker.Blood.rh_factor()
      "+"

  """
  @spec rh_factor() :: String.t()
  def rh_factor, do: Enum.random(@rh_factors)

  @doc """
  Generates a random blood type in medical notation.

  Returns a descriptive string combining the ABO type and Rh factor. Set
  `verbose: true` for the extended `"Type X, Rh Y"` form.

  ## Options

  - `:verbose` - When `true`, uses full descriptive text. Defaults to `false`.

  ## Examples

      iex> NeoFaker.Blood.medical_notation()
      "B positive"

      iex> NeoFaker.Blood.medical_notation(verbose: true)
      "Type AB, Rh positive"

  """
  @spec medical_notation(Keyword.t()) :: String.t()
  def medical_notation(opts \\ []) do
    blood_type = type()
    rh_text = if rh_factor() == "+", do: "positive", else: "negative"

    if Options.get(opts, :verbose, false) do
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
  def all_types, do: @blood_types

  @doc """
  Returns both possible Rh factors.

  ## Examples

      iex> NeoFaker.Blood.all_rh_factors()
      ["+", "-"]

  """
  @spec all_rh_factors() :: [String.t()]
  def all_rh_factors, do: @rh_factors
end
