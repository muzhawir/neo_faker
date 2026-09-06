defmodule NeoFaker.Color.HslaGenerator do
  @moduledoc false

  alias NeoFaker.Number

  @doc """
  Generates a random HSLA color tuple with hue (0–359), saturation and lightness (0–100),
  and alpha (0.0–1.0) rounded to one decimal place.
  """
  @spec color_tuple() :: {0..359, 0..100, 0..100, float()}
  def color_tuple do
    {Number.between(0, 359), Number.between(), Number.between(),
     Float.round(Number.between(0.0, 1.0), 1)}
  end

  @doc """
  Formats an HSLA color tuple as a W3C-compliant string in the form "hsla(h, s%, l%, a)".
  """
  @spec color_w3c({0..359, 0..100, 0..100, float()}) :: String.t()
  def color_w3c({h, s, l, a}), do: "hsla(#{h}, #{s}%, #{l}%, #{a})"
end
