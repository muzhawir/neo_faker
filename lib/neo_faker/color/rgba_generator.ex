defmodule NeoFaker.Color.RgbaGenerator do
  @moduledoc false

  # Each channel is picked independently in its valid range; this generates a
  # valid RGBA value, not a conversion from another color space.

  alias NeoFaker.Number

  @doc """
  Alpha is rounded to one decimal place (e.g. `0.7`, not `0.6842`), matching the precision
  real-world RGBA values are usually written with by hand.
  """
  @spec color_tuple() :: {0..255, 0..255, 0..255, float()}
  def color_tuple do
    {Number.between(0, 255), Number.between(0, 255), Number.between(0, 255),
     Float.round(Number.between(0.0, 1.0), 1)}
  end

  @doc """
  Formats an RGBA tuple as the W3C `rgba(r, g, b, a)` string form.
  """
  @spec color_w3c({0..255, 0..255, 0..255, float()}) :: String.t()
  def color_w3c({r, g, b, a}), do: "rgba(#{r}, #{g}, #{b}, #{a})"
end
