defmodule NeoFaker.Color.RgbGenerator do
  @moduledoc false

  # Each channel is picked independently in its valid range; this generates a
  # valid RGB value, not a conversion from another color space.

  alias NeoFaker.Number

  @spec color_tuple() :: {0..255, 0..255, 0..255}
  def color_tuple, do: {Number.between(0, 255), Number.between(0, 255), Number.between(0, 255)}

  @doc """
  Formats an RGB tuple as the W3C `rgb(r, g, b)` string form.
  """
  @spec color_w3c({0..255, 0..255, 0..255}) :: String.t()
  def color_w3c({r, g, b}), do: "rgb(#{r}, #{g}, #{b})"
end
