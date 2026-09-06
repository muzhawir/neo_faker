defmodule NeoFaker.Date.Generator do
  @moduledoc false

  @typedoc "Date format either `Date` struct or iso8601 `YYYY-MM-DD`"
  @type date_format :: :struct | :iso8601

  @doc """
  Generate a random date with specified range.

  Returns a random date as a `Date` struct when the format is `:struct` or a string in the format
  `YYYY-MM-DD` when the format is `:iso8601`.
  """
  @spec add(Range.t(), date_format()) :: Date.t() | String.t()
  def add(range, format) do
    date = NaiveDateTime.local_now() |> NaiveDateTime.to_date() |> Date.add(Enum.random(range))

    case format do
      :struct -> date
      :iso8601 -> Date.to_iso8601(date)
    end
  end

  @doc """
  Generate a random date between two dates.

  Returns a random date between `start` and `finish` as a `Date` struct when the format is
  `:struct` or a string in the format `YYYY-MM-DD` when the format is `:iso8601`.
  """
  @spec between(Date.t(), Date.t(), date_format()) :: Date.t() | String.t()
  def between(start, finish, format) do
    date = start |> Date.range(finish) |> Enum.random()

    case format do
      :struct -> date
      :iso8601 -> Date.to_iso8601(date)
    end
  end

  @doc """
  Returns the current local date as a `Date` struct.
  """
  @spec local_date_now() :: Date.t()
  def local_date_now, do: NaiveDateTime.to_date(NaiveDateTime.local_now())
end
