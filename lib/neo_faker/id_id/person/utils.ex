defmodule NeoFaker.IdId.Person.Utils do
  @moduledoc false

  alias NeoFaker.Number

  @min_age_years -90
  @max_age_years -18

  @doc """
  Generate a serial number with a specified maximum number and padding count.
  """
  @spec serial_number(non_neg_integer(), non_neg_integer()) :: String.t()
  def serial_number(max_number, pad_count) do
    1 |> Number.between(max_number) |> to_string() |> String.pad_leading(pad_count, "0")
  end

  
  
  @doc """
  Generates a random birth date string in `DDMMYY` format, selecting a date between 90 and 18 years ago.
  
  The day component is randomly chosen as either the actual day or the day plus 40 to represent a female code.
  """
  def birth_date do
    today = NaiveDateTime.local_now()

    %Date{year: year, month: month, day: day} =
      today
      |> Date.shift(year: @min_age_years)
      |> Date.range(Date.shift(today, year: @max_age_years))
      |> Enum.random()

    formatted_year = year |> to_string() |> String.slice(2, 2)
    formatted_month = month |> to_string() |> String.pad_leading(2, "0")
    formatted_day = [day, day + 40] |> Enum.random() |> to_string() |> String.pad_leading(2, "0")

    "#{formatted_day}#{formatted_month}#{formatted_year}"
  end
end
