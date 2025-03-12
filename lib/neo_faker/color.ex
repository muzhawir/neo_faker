defmodule NeoFaker.Color do
  @moduledoc """
  Provides functions for generating random colors.

  This module includes utilities for generating colors in various formats.
  """
  @moduledoc since: "0.8.0"

  alias NeoFaker.Color.Util

  @doc """
  Generates a CMYK color.

  Returns a CMYK color. If no options are provided, the color is returned in tuple format.

  ## Options

  - `:format` - Specifies the output format.

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

  Returns a HEX color. If no options are provided, the color is returned in six-digit format.

  ## Options

  - `:format` - Specifies the output format.

  The values for `:format` can be:

  - `nil` - Returns the color in six-digit format (default).
  - `:three_digit` - Returns the color in three-digit format.
  - `:four_digit` - Returns the color in four-digit format.
  - `:eight_digit` - Returns the color in eight-digit format.

  ## Examples

      iex> NeoFaker.Color.hex()
      "#613583"

      iex> NeoFaker.Color.hex(format: :three_digit)
      "#365"

  """
  @spec hex(Keyword.t()) :: String.t()
  defdelegate hex(opts \\ []), to: Util, as: :hex

  @doc """
  Generates an HSL color.

  This function behaves the same way as `cmyk/1`. See `cmyk/1` for more details.
  """
  @spec hsl(Keyword.t()) :: tuple() | String.t()
  defdelegate hsl(opts \\ []), to: Util, as: :hsl

  @doc """
  Generates an HSLA color.

  This function behaves the same way as `cmyk/1`. See `cmyk/1` for more details.
  """
  @spec hsla(Keyword.t()) :: tuple() | String.t()
  defdelegate hsla(opts \\ []), to: Util, as: :hsla

  @doc """
  Generates a keyword color.

  Returns a keyword color. If no options are provided, all category colors are returned.


  ## Options

  - `:category` - Specifies the category of keyword colors.
  - `:locale` - Specifies the locale to use.

  The values for `:category` can be:

  - `nil` - Returns all keyword colors (default).
  - `:basic` - Returns basic keyword colors.
  - `:extended` - Returns extended keyword colors.

  The values for `:locale` can be:

  - `nil` - Uses the default locale `"default"`.
  - `:id_id` - Uses the Indonesian locale, for example.

  ## Examples

      iex> NeoFaker.Color.keyword()
      "blueviolet"

      iex> NeoFaker.Color.keyword(category: :basic)
      "purple"

  """
  @spec keyword(Keyword.t()) :: String.t()
  defdelegate keyword(opts \\ []), to: Util, as: :keyword

  @doc """
  Generates an RGB color.

  This function behaves the same way as `cmyk/1`. See `cmyk/1` for more details.
  """
  @spec rgb(Keyword.t()) :: tuple() | String.t()
  defdelegate rgb(opts \\ []), to: Util, as: :rgb

  @doc """
  Generates an RGBA color.

  This function behaves the same way as `cmyk/1`. See `cmyk/1` for more details.
  """
  @spec rgba(Keyword.t()) :: tuple() | String.t()
  defdelegate rgba(opts \\ []), to: Util, as: :rgba
end
