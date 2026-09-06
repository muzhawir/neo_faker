defmodule NeoFaker.Color.CMYK do
  @moduledoc false

  import NeoFaker.Number, only: [between: 0]

  @doc """
  Generates a random CMYK color tuple with each component between 0 and 100.
  """
  def color_tuple, do: {between(), between(), between(), between()}

  @doc """
  Formats a CMYK color tuple as a W3C-compliant string in the form "cmyk(c%, m%, y%, k%)".
  """
  def color_w3c({c, m, y, k}), do: "cmyk(#{c}%, #{m}%, #{y}%, #{k}%)"
end
