defmodule NeoFaker.Color.Generator do
  @moduledoc false

  # Every channel is drawn independently from its valid range, so each value
  # is a valid color in its own model rather than a conversion from another.

  alias NeoFaker.Data

  @hex_digits ~c"0123456789ABCDEF"
  @keyword_file "keyword.exs"

  @type model :: :cmyk | :hsl | :hsla | :rgb | :rgba

  @doc """
  Returns a random color tuple in the given color model.
  """
  @spec color(model()) :: tuple()
  def color(:cmyk), do: {percent(), percent(), percent(), percent()}
  def color(:hsl), do: {hue(), percent(), percent()}
  def color(:hsla), do: {hue(), percent(), percent(), alpha()}
  def color(:rgb), do: {byte(), byte(), byte()}
  def color(:rgba), do: {byte(), byte(), byte(), alpha()}

  @doc """
  Returns `digits` random uppercase hexadecimal characters.
  """
  @spec hex(3 | 4 | 6 | 8) :: String.t()
  def hex(digits), do: for(_ <- 1..digits, into: "", do: <<Enum.random(@hex_digits)>>)

  @doc """
  Formats a color tuple as a CSS functional notation string.
  """
  @spec to_w3c(model(), tuple()) :: String.t()
  def to_w3c(:cmyk, {c, m, y, k}), do: "cmyk(#{c}%, #{m}%, #{y}%, #{k}%)"
  def to_w3c(:hsl, {h, s, l}), do: "hsl(#{h}, #{s}%, #{l}%)"
  def to_w3c(:hsla, {h, s, l, a}), do: "hsla(#{h}, #{s}%, #{l}%, #{a})"
  def to_w3c(:rgb, {r, g, b}), do: "rgb(#{r}, #{g}, #{b})"
  def to_w3c(:rgba, {r, g, b, a}), do: "rgba(#{r}, #{g}, #{b}, #{a})"

  @doc """
  Returns a random CSS color keyword from `category`. `:all` pools every
  category, counting a keyword listed in several categories only once.
  """
  @spec keyword(:all | :basic | :extended, atom() | nil) :: String.t()
  def keyword(:all, locale),
    do: Data.random_value(NeoFaker.Color, @keyword_file, ["basic", "extended"], locale: locale)

  def keyword(category, locale),
    do: Data.random_value(NeoFaker.Color, @keyword_file, Atom.to_string(category), locale: locale)

  defp percent, do: Enum.random(0..100)
  defp byte, do: Enum.random(0..255)
  defp hue, do: Enum.random(0..359)

  # One decimal place, the precision alpha values are usually written with.
  # Drawing from 0..10 keeps 0.0 and 1.0 as likely as every other step.
  defp alpha, do: Enum.random(0..10) / 10
end
