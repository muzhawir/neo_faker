defmodule NeoFaker.Color.RgbaGenerator do
  @moduledoc false

  alias NeoFaker.Number

  @doc """
  Generates a random RGBA color tuple with red, green, and blue components between 0 and 255,
  and an alpha value between 0.0 and 1.0 rounded to one decimal place.
  """
  @spec color_tuple() :: {0..255, 0..255, 0..255, float()}
  def color_tuple do
    {Number.between(0, 255), Number.between(0, 255), Number.between(0, 255),
     Float.round(Number.between(0.0, 1.0), 1)}
  end

  @doc """
  Formats an RGBA color tuple as a W3C-compliant string in the form "rgba(r, g, b, a)".
  """
  @spec color_w3c({0..255, 0..255, 0..255, float()}) :: String.t()
  def color_w3c({r, g, b, a}), do: "rgba(#{r}, #{g}, #{b}, #{a})"
end
