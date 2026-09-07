defmodule NeoFaker.Color.HslaGenerator do
  @moduledoc false

  # Each channel is picked independently in its valid range; this generates a
  # valid HSLA value, not a conversion from another color space.

  alias NeoFaker.Number

  @doc """
  Alpha is rounded to one decimal place (e.g. `0.7`, not `0.6842`), matching the precision
  real-world HSLA values are usually written with by hand.
  """
  @spec color_tuple() :: {0..359, 0..100, 0..100, float()}
  def color_tuple do
    {Number.between(0, 359), Number.between(), Number.between(),
     Float.round(Number.between(0.0, 1.0), 1)}
  end

  @doc """
  Formats an HSLA tuple as the W3C `hsla(h, s%, l%, a)` string form.
  """
  @spec color_w3c({0..359, 0..100, 0..100, float()}) :: String.t()
  def color_w3c({h, s, l, a}), do: "hsla(#{h}, #{s}%, #{l}%, #{a})"
end
