defmodule NeoFaker.Date.Validator do
  @moduledoc false

  @doc """
  Returns `:ok` if `start` and `finish` are `Date` structs with `start` on or before
  `finish`, raising `ArgumentError` otherwise.
  """
  @spec validate_date_order!(term(), term()) :: :ok
  def validate_date_order!(%Date{} = start, %Date{} = finish) do
    if Date.after?(start, finish) do
      raise ArgumentError,
            "start date must be on or before finish date, " <>
              "got: start=#{inspect(start)}, finish=#{inspect(finish)}"
    else
      :ok
    end
  end

  def validate_date_order!(start, finish) do
    raise ArgumentError,
          "start and finish must be Date structs, " <>
            "got: start=#{inspect(start)}, finish=#{inspect(finish)}"
  end
end
