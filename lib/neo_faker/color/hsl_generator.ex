defmodule NeoFaker.Color.HslGenerator do
  @moduledoc false

  alias NeoFaker.Number

  @doc """
  Generates a random HSL color tuple with hue between 0 and 359, and saturation and lightness
  between 0 and 100.
  """
  def color_tuple, do: {Number.between(0, 359), Number.between(), Number.between()}

  @doc """
  Formats an HSL color tuple as a W3C-compliant string in the form "hsl(h, s%, l%)".
  """
  def color_w3c({h, s, l}), do: "hsl(#{h}, #{s}%, #{l}%)"
end
