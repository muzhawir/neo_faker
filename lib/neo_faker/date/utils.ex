defmodule NeoFaker.Date.Utils do
  @moduledoc false

  @doc """
  Generate a random NIK.

  This function delegates the call to `NeoFaker.Date.add/2`.
  """
  @spec add(Range.t(), Keyword.t()) :: Date.t()
  def add(range \\ -365..365, opts \\ []) do
    type = Keyword.get(opts, :format, :date)

    random_date(range, type)
  end

  # Generate a random date with specified format.
  defp random_date(range, :date), do: Date.add(Date.utc_today(), Enum.random(range))

  defp random_date(range, :iso8601) do
    Date.utc_today() |> Date.add(Enum.random(range)) |> Date.to_iso8601()
  end
end
