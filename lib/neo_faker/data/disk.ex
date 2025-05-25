defmodule NeoFaker.Data.Disk do
  @moduledoc false

  @priv_dir :neo_faker |> :code.priv_dir() |> to_string()
  @data_dir Path.join(@priv_dir, "data")

  @doc """
  Reads and evaluates a file, returning its contents.
  """
  @spec fetch_file!(String.t()) :: any()
  def fetch_file!(path) do
    path |> File.read!() |> Code.eval_string() |> elem(0)
  end

  @doc """
  Returns the path to the data directory.
  """
  @spec data_path() :: String.t()
  def data_path, do: @data_dir
end
