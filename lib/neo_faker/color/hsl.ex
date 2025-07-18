defmodule NeoFaker.Color.HSL do
  @moduledoc false

  import NeoFaker.Number, only: [between: 0, between: 2]

  @doc """
  Generates a random HSL color tuple with hue between 0 and 359, and saturation and lightness
  between 0 and 100.
  """
  def color_tuple, do: {between(0, 359), between(), between()}

  @doc """
  Formats an HSL color tuple as a W3C-compliant string in the form "hsl(h, s%, l%)".
  """
  def color_w3c({h, s, l}), do: "hsl(#{h}, #{s}%, #{l}%)"
end
