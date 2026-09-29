defmodule NeoFaker.Locales.IdId.Person.Generator do
  @moduledoc false

  # Parts of a Nomor Induk Kependudukan (NIK): a 16-digit number made of a
  # 6-digit region code (province, regency, district), a 6-digit DDMMYY birth
  # date, and a 4-digit serial.

  @doc """
  Returns a random number from `1..max`, zero-padded to `width` digits.
  """
  @spec serial_number(pos_integer(), pos_integer()) :: String.t()
  def serial_number(max, width) do
    1..max |> Enum.random() |> Integer.to_string() |> String.pad_leading(width, "0")
  end

  @doc """
  Returns a random six-digit region code: province `11` to `92`, then regency and
  district.
  """
  @spec region_code() :: String.t()
  def region_code do
    "#{Enum.random(11..92)}#{serial_number(79, 2)}#{serial_number(53, 2)}"
  end

  @doc """
  Returns a random `DDMMYY` birth date for someone aged 18 to 90 today.

  For women, the NIK adds 40 to the day of birth, so half of the results have a day
  from `41` to `71`.
  """
  @spec birth_date() :: String.t()
  def birth_date do
    today = Date.utc_today()

    date =
      today |> Date.shift(year: -90) |> Date.range(Date.shift(today, year: -18)) |> Enum.random()

    day = Enum.random([date.day, date.day + 40])

    pad2(day) <> pad2(date.month) <> pad2(rem(date.year, 100))
  end

  defp pad2(n), do: n |> Integer.to_string() |> String.pad_leading(2, "0")
end
