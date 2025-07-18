defmodule NeoFaker.Color.RGB do
  @moduledoc false

  import NeoFaker.Number, only: [between: 2]

  @doc """
  Generates a tuple representing an RGB color with each component randomly selected between
  0 and 255.
  """
  def color_tuple, do: {between(0, 255), between(0, 255), between(0, 255)}

  @doc """
  Formats an RGB color tuple as a W3C-compliant string in the form "rgb(r, g, b)".
  """
  def color_w3c({r, g, b}), do: "rgb(#{r}, #{g}, #{b})"
end
