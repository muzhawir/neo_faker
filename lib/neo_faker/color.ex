defmodule NeoFaker.Color do
  @moduledoc """
  Provides functions for generating colors.

  This module includes functions for generating random colors, such as CMYK, HEX, and RGB colors.
  """

  import NeoFaker.Helper.Generator, only: [random: 4]

  alias NeoFaker.Color.Util
  alias NeoFaker.Helper.Generator

  @module __MODULE__

  @doc """
  Generates a CMYK color.

  Returns a CMYK color, if no options are provided it returns the color in tuple format.

  ## Options

  - `:format` - Specifies the format of the output. Default is `:tuple`.

  The values for `:format` can be:

  - `nil` - Returns the color in tuple format (default).
  - `:w3c` - Returns the color in W3C format.

  ## Examples

      iex> NeoFaker.Color.cmyk()
      {0, 25, 50, 100}

      iex> NeoFaker.Color.cmyk(format: :w3c)
      "cmyk(0%, 25%, 50%, 100%)"

  """
  @spec cmyk(Keyword.t()) :: tuple() | String.t()
  defdelegate cmyk(opts \\ []), to: Util, as: :cmyk

  @doc """
  Generates a HEX color.

  Returns a HEX color, if no options are provided it returns the color in tuple format.

  ## Options

  - `:format` - Specifies the format of the output. Default is `:tuple`.

  The values for `:format` can be:

  - `nil` - Returns the color in tuple format (default).
  - `:three_digit` - Returns the color in three-digit format.
  - `:four_digit` - Returns the color in four-digit format.
  - `:eight_digit` - Returns the color in eight-digit format.

  ## Examples

      iex> NeoFaker.Color.hex()
      "#613583"

      iex> NeoFaker.Color.hex(format: :three_digit)
      "#365"

      iex> NeoFaker.Color.hex(format: :four_digit)
      "#365F"

      iex> NeoFaker.Color.hex(format: :eight_digit)
      "#613583FF"

  """
  @spec hex(Keyword.t()) :: String.t()
  defdelegate hex(opts \\ []), to: Util, as: :hex

  @doc """
  Generates an HSL color.

  Returns an HSL color, if no options are provided it returns the color in tuple format.

  ## Options

  - `:format` - Specifies the format of the output. Default is `:tuple`.

  The values for `:format` can be:

  - `nil` - Returns the color in tuple format (default).
  - `:w3c` - Returns the color in W3C format.

  ## Examples

      iex> NeoFaker.Color.hsl()
      {270, 40, 50}

      iex> NeoFaker.Color.hsl(format: :w3c)
      "hsl(270, 40%, 50%)"

  """
  @spec hsl(Keyword.t()) :: tuple() | String.t()
  defdelegate hsl(opts \\ []), to: Util, as: :hsl

  @doc """
  Generates an HSLA color.

  Returns an HSLA color, if no options are provided it returns the color in tuple format.

  ## Options

  - `:format` - Specifies the format of the output. Default is `:tuple`.

  The values for `:format` can be:

  - `nil` - Returns the color in tuple format (default).
  - `:w3c` - Returns the color in W3C format.

  ## Examples

      iex> NeoFaker.Color.hsla()
      {270, 40, 50, 0.5}

      iex> NeoFaker.Color.hsla(format: :w3c)
      "hsla(270, 40%, 50%, 0.5)"

  """
  @spec hsla(Keyword.t()) :: tuple() | String.t()
  defdelegate hsla(opts \\ []), to: Util, as: :hsla

  def keyword(opts \\ []) do
    case Keyword.get(opts, :category) do
      nil -> get_all_colors(opts)
      :basic -> random(@module, "keyword.exs", "basic", opts)
      :extended -> random(@module, "keyword.exs", "extended", opts)
    end
  end

  defp get_all_colors(opts) do
    @module
    |> Generator.fetch_data("keyword.exs", opts)
    |> Map.values()
    |> List.flatten()
    |> Enum.random()
  end
end
