defmodule NeoFaker.Color.HslGenerator do
  @moduledoc false

  # Each channel is picked independently in its valid range; this generates a
  # valid HSL value, not a conversion from another color space.

  alias NeoFaker.Number

  @spec color_tuple() :: {0..359, 0..100, 0..100}
  def color_tuple, do: {Number.between(0, 359), Number.between(), Number.between()}

  @doc """
  Formats an HSL tuple as the W3C `hsl(h, s%, l%)` string form.
  """
  @spec color_w3c({0..359, 0..100, 0..100}) :: String.t()
  def color_w3c({h, s, l}), do: "hsl(#{h}, #{s}%, #{l}%)"
end
