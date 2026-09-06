defmodule NeoFaker.Color.RgbGenerator do
  @moduledoc false

  alias NeoFaker.Number

  @doc """
  Generates a tuple representing an RGB color with each component randomly selected between
  0 and 255.
  """
  def color_tuple, do: {Number.between(0, 255), Number.between(0, 255), Number.between(0, 255)}

  @doc """
  Formats an RGB color tuple as a W3C-compliant string in the form "rgb(r, g, b)".
  """
  def color_w3c({r, g, b}), do: "rgb(#{r}, #{g}, #{b})"
end
