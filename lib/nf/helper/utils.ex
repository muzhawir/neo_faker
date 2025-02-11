defmodule Nf.Helper.Utils do
  @moduledoc false

  @doc """
  Loads and evaluates the given locale file.

  This function reads and evaluates an `.exs` file from the given `path`,
  returning the evaluated result.
  """
  def load_locale_file(path), do: path |> Code.eval_file() |> elem(0)
end
