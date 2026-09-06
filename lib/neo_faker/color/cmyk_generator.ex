defmodule NeoFaker.Color.CmykGenerator do
  @moduledoc false

  alias NeoFaker.Number

  @doc """
  Generates a random CMYK color tuple with each component between 0 and 100.
  """
  def color_tuple, do: {Number.between(), Number.between(), Number.between(), Number.between()}

  @doc """
  Formats a CMYK color tuple as a W3C-compliant string in the form "cmyk(c%, m%, y%, k%)".
  """
  def color_w3c({c, m, y, k}), do: "cmyk(#{c}%, #{m}%, #{y}%, #{k}%)"
end
