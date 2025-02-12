defmodule Nf.Helper do
  @moduledoc false

  import Nf.Helper.Utils

  @doc """
  Returns a random value or a list of random values.

  If the requested data is not yet cached, it is first loaded from the locale files and cached
  for future retrieval.
  """
  @spec get_random_data(String.t(), String.t(), String.t(), integer()) :: String.t() | [String.t()]
  def get_random_data(module, file, key, amount \\ 1) do
    module |> load_cache(file, key) |> random_result(amount)
  end
end
