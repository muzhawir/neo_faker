defmodule NeoFaker.Helpers.Formatter do
  @moduledoc false
  @moduledoc since: "0.14.0"

  # Shared string-shaping helpers used across several domain modules.

  @doc """
  Applies case transformation to a string.

  ## Options

  - `:upper` - Converts to uppercase
  - `:lower` - Converts to lowercase
  - `:none` - Returns unchanged

  ## Examples

      iex> NeoFaker.Helpers.Formatter.apply_case("Hello", :upper)
      "HELLO"

      iex> NeoFaker.Helpers.Formatter.apply_case("Hello", :lower)
      "hello"

      iex> NeoFaker.Helpers.Formatter.apply_case("Hello", :none)
      "Hello"

  """
  @spec apply_case(String.t(), :upper | :lower | :none) :: String.t()
  def apply_case(string, :upper), do: String.upcase(string)
  def apply_case(string, :lower), do: String.downcase(string)
  def apply_case(string, :none), do: string

  @doc """
  Reduces a string to a lowercase alphanumeric token: downcases it, then drops
  every character that is not `a-z` or `0-9`.

  `NeoFaker.Text.word/0` can return a word carrying a hyphen, an apostrophe, or a
  capital (`"T-shirt"`, `"o'clock"`, `"long-term"`). `NeoFaker.Internet` joins
  such words with a separator to build usernames, domain labels, and slugs, so
  each piece has to collapse to a bare token first (`"tshirt"`, `"oclock"`,
  `"longterm"`), otherwise the extra character reads as a second segment.

  ## Examples

      iex> NeoFaker.Helpers.Formatter.slugify("T-shirt")
      "tshirt"

      iex> NeoFaker.Helpers.Formatter.slugify("hello")
      "hello"

  """
  @spec slugify(String.t()) :: String.t()
  def slugify(string), do: string |> String.downcase() |> String.replace(~r/[^a-z0-9]/, "")
end
