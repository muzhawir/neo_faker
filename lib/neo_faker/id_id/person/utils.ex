defmodule NeoFaker.IdId.Person.Utils do
  @moduledoc false
  alias NeoFaker.Number

  @min_age_years -90
  @max_age_years -18

  @doc """
  Generate a random NIK.

  This function delegates the call to `NeoFaker.IdId.Person.nik/0`.
  """
  @spec nik() :: String.t()
  def nik do
    province_number = Number.between(11, 92)
    regency_number = 1 |> Number.between(79) |> to_string() |> String.pad_leading(2, "0")
    district_number = 1 |> Number.between(53) |> to_string() |> String.pad_leading(2, "0")
    serial_number = 1 |> Number.between(9999) |> to_string() |> String.pad_leading(4, "0")

    "#{province_number}#{regency_number}#{district_number}#{birth_date()}#{serial_number}"
  end

  # Generate a random birth date with either the exact day or the day + 40 (for the female code).
  defp birth_date do
    today = Date.utc_today()

    %Date{year: year, month: month, day: day} =
      today
      |> Date.shift(year: @min_age_years)
      |> Date.range(Date.shift(today, year: @max_age_years))
      |> Enum.random()

    formatted_year = year |> Integer.to_string() |> String.slice(2, 2)
    formatted_month = month |> Integer.to_string() |> String.pad_leading(2, "0")
    formatted_day = Enum.random([day, day + 40])

    "#{formatted_day}#{formatted_month}#{formatted_year}"
  end
end
