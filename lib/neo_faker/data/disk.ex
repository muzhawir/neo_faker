defmodule NeoFaker.Data.Disk do
  @moduledoc false

  @doc """
  Evaluates the contents of a file and returns the result.
  """
  @spec evaluate_file!(String.t()) :: any()
  def evaluate_file!(path) do
    if File.exists?(path) do
      path
      |> File.read!()
      |> Code.eval_string()
      |> elem(0)
    else
      raise File.Error, reason: :enoent
    end
  end

  @doc """
  Returns the path to the data directory.
  """
  @spec data_path() :: String.t()
  def data_path, do: Path.join([File.cwd!(), "priv", "data"])
end
