defmodule NeoFaker.IdId.Person.Utils do
  @moduledoc false

  @min_age_years -90
  @max_age_years -18

  @doc """
  Generate a random birth date with either the exact day or the day `n+40` (for the female code).
  """
  @spec birth_date() :: String.t()
  def birth_date do
    today = Date.utc_today()

    %Date{year: year, month: month, day: day} =
      today
      |> Date.shift(year: @min_age_years)
      |> Date.range(Date.shift(today, year: @max_age_years))
      |> Enum.random()

    formatted_year = year |> to_string() |> String.slice(2, 2)
    formatted_month = month |> to_string() |> String.pad_leading(2, "0")

    formatted_day =
      [day, day + 40]
      |> Enum.random()
      |> to_string()
      |> String.pad_leading(2, "0")

    "#{formatted_day}#{formatted_month}#{formatted_year}"
  end
end
