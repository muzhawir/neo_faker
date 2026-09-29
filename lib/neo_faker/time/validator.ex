defmodule NeoFaker.Time.Validator do
  @moduledoc false

  @doc """
  Returns `:ok` if `start` and `finish` are `Time` structs with `start` at or before
  `finish`, raising `ArgumentError` otherwise.
  """
  @spec validate_time_order!(term(), term()) :: :ok
  def validate_time_order!(%Time{} = start, %Time{} = finish) do
    if Time.after?(start, finish) do
      raise ArgumentError,
            "start time must be at or before finish time, " <>
              "got: start=#{inspect(start)}, finish=#{inspect(finish)}"
    else
      :ok
    end
  end

  def validate_time_order!(start, finish) do
    raise ArgumentError,
          "start and finish must be Time structs, " <>
            "got: start=#{inspect(start)}, finish=#{inspect(finish)}"
  end
end
