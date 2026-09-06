defmodule NeoFaker.Color.CmykGenerator do
  @moduledoc false

  # Each channel is picked independently in its valid range; this generates a
  # valid CMYK value, not a conversion from another color space.

  alias NeoFaker.Number

  @spec color_tuple() :: {0..100, 0..100, 0..100, 0..100}
  def color_tuple, do: {Number.between(), Number.between(), Number.between(), Number.between()}

  @doc """
  Formats a CMYK tuple as the W3C `cmyk(c%, m%, y%, k%)` string form.
  """
  @spec color_w3c({0..100, 0..100, 0..100, 0..100}) :: String.t()
  def color_w3c({c, m, y, k}), do: "cmyk(#{c}%, #{m}%, #{y}%, #{k}%)"
end
