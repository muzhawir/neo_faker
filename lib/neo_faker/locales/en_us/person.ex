defmodule NeoFaker.Locales.EnUs.Person do
  @moduledoc """
  Functions for generating personal details specific to the United States.
  """
  @moduledoc since: "0.9.0"

  alias NeoFaker.Locales.EnUs.Person.Generator

  @doc """
  Generates a random Social Security Number in `AAA-GG-SSSS` format.

  The number follows the structural rules of the Social Security Administration: the
  area is never `000`, `666`, or `900` to `999`, the group is never `00`, and the serial
  is never `0000`. It is not checked against numbers actually issued, so it may belong to
  a real person; do not use it outside test and development data.

  ## Examples

      iex> NeoFaker.Locales.EnUs.Person.ssn()
      "184-63-2006"

  """
  @spec ssn() :: String.t()
  def ssn do
    Enum.join(
      [Generator.area_number(), Generator.serial_number(99, 2), Generator.serial_number(9999, 4)],
      "-"
    )
  end
end
