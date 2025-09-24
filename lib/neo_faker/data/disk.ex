defmodule NeoFaker.Data.Disk do
  @moduledoc false

  @doc """
  Reads and evaluates a file, returning its contents.
  """
  @spec fetch_file!(String.t()) :: any()
  def fetch_file!(path), do: path |> File.read!() |> Code.eval_string([], __ENV__) |> elem(0)

  @doc """
  Returns the path to the data directory.
  """
  @spec data_path() :: String.t()
  def data_path, do: :neo_faker |> :code.priv_dir() |> to_string() |> Path.join("data")
end
