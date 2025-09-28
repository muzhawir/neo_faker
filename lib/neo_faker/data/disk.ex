defmodule NeoFaker.Data.Disk do
  @moduledoc false

  @doc """
  Reads and evaluates a file, returning its contents.

  Raises `File.Error` if the file does not exist or cannot be read.
  """
  @spec fetch_file!(String.t()) :: any()
  def fetch_file!(path), do: path |> File.read!() |> Code.eval_string([], __ENV__) |> elem(0)

  @doc """
  Returns the path to the data directory.

  The data directory is located in the `priv` directory of the `:neo_faker` application.
  """
  @spec data_path() :: String.t()
  def data_path, do: :neo_faker |> :code.priv_dir() |> to_string() |> Path.join("data")
end
