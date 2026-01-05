defmodule NeoFaker.Blood do
  @moduledoc """
  Functions for generating blood types.

  This module provides utilities to generate random blood groups, blood types, and Rh factors
  following the ABO blood group system classification.
  """
  @moduledoc since: "0.3.1"

  alias NeoFaker.Helpers.Options

  @blood_types ~w[A B AB O]
  @rh_factors ~w[+ -]
  @valid_formats [:group, :type_only, :rh_only]

  @doc """
  Generates a random blood group.

  Returns a blood group, which consists of a blood type (`A`, `B`, `AB`, or `O`) combined with an
  Rh factor (`+` or `-`), forming a complete blood group according to the ABO and Rh blood
  group systems.

  ## Parameters

  - `opts` - Keyword list of options:
    - `:format` - Specifies the output format. Defaults to `:group`.

  ## Options

  The values for `:format` can be:

  - `:group` - Returns the full blood group (e.g., `"B+"`) (default).
  - `:type_only` - Returns only the blood type (e.g., `"B"`).
  - `:rh_only` - Returns only the Rh factor (e.g., `"+"`).

  ## Examples

      iex> NeoFaker.Blood.group()
      "B+"

      iex> NeoFaker.Blood.group(format: :group)
      "AB-"

      iex> NeoFaker.Blood.group(format: :type_only)
      "O"

      iex> NeoFaker.Blood.group(format: :rh_only)
      "-"

  """
  @spec group(Keyword.t()) :: String.t()
  def group(opts \\ []) do
    format = Options.get(opts, :format, :group)

    validate_format!(format)

    case format do
      :group -> "#{type()}#{rh_factor()}"
      :type_only -> type()
      :rh_only -> rh_factor()
    end
  end

  @doc """
  Generates a random blood type.

  Returns a string representing a blood type without the Rh factor. The blood type can be
  one of the four main types in the ABO blood group system: `A`, `B`, `AB`, or `O`.

  ## Examples

      iex> NeoFaker.Blood.type()
      "B"

      iex> NeoFaker.Blood.type()
      "AB"

      iex> NeoFaker.Blood.type()
      "O"

      iex> NeoFaker.Blood.type()
      "A"

  """
  @spec type() :: String.t()
  def type, do: Enum.random(@blood_types)

  @doc """
  Generates a random Rh factor.

  Returns a string representing the Rh factor, which can be either `+` (positive) or
  `-` (negative). The Rh factor indicates the presence or absence of the Rh antigen.

  ## Examples

      iex> NeoFaker.Blood.rh_factor()
      "+"

      iex> NeoFaker.Blood.rh_factor()
      "-"

  """
  @spec rh_factor() :: String.t()
  def rh_factor, do: Enum.random(@rh_factors)

  @doc """
  Generates a random blood type with full medical notation.

  Returns a blood group with medical notation including the ABO type and Rh factor
  in a more descriptive format suitable for medical documentation.

  ## Parameters

  - `opts` - Keyword list of options:
    - `:verbose` - When `true`, uses full descriptive text. Defaults to `false`.

  ## Examples

      iex> NeoFaker.Blood.medical_notation()
      "B positive"

      iex> NeoFaker.Blood.medical_notation(verbose: true)
      "Type AB, Rh positive"

      iex> NeoFaker.Blood.medical_notation(verbose: false)
      "O negative"

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
  Returns a list of all possible blood groups.

  Returns all 8 possible blood group combinations in the ABO and Rh blood group systems.

  ## Examples

      iex> NeoFaker.Blood.all_groups()
      ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"]

  """
  @spec all_groups() :: [String.t()]
  def all_groups do
    for blood_type <- @blood_types, rh <- @rh_factors do
      "#{blood_type}#{rh}"
    end
  end

  @doc """
  Returns a list of all blood types.

  Returns all 4 blood types in the ABO blood group system.

  ## Examples

      iex> NeoFaker.Blood.all_types()
      ["A", "B", "AB", "O"]

  """
  @spec all_types() :: [String.t()]
  def all_types, do: @blood_types

  @doc """
  Returns a list of all Rh factors.

  Returns both possible Rh factors.

  ## Examples

      iex> NeoFaker.Blood.all_rh_factors()
      ["+", "-"]

  """
  @spec all_rh_factors() :: [String.t()]
  def all_rh_factors, do: @rh_factors

  # Private functions

  @spec validate_format!(atom()) :: :ok
  defp validate_format!(format) do
    case Options.validate_enum(:format, format, @valid_formats) do
      :ok ->
        :ok

      {:error, reason} ->
        raise ArgumentError, reason
    end
  end
end
