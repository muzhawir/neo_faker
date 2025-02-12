defmodule Nf.Helper do
  @moduledoc false

  import Nf.Helper.Cache

  @type data :: String.t() | [String.t()]

  @doc """
  Returns a random value or a list of random values.

  If the requested data is not yet cached, it is first loaded from the locale files and cached
  for future retrieval.
  """
  @spec get_random_value(String.t(), String.t(), String.t(), integer()) :: data()
  def get_random_value(module, file, key, amount \\ 1) do
    module |> load_cache(file, key) |> random_result(amount)
  end

  @doc """
  Returns a random value or a list of random values.
  """
  @spec random_result([String.t()], integer()) :: data()
  def random_result(list, 1), do: Enum.random(list)
  def random_result(list, -1), do: Enum.shuffle(list)
  def random_result(list, amount), do: list |> Enum.shuffle() |> Enum.take(amount)
end
