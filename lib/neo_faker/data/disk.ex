defmodule NeoFaker.Data.Disk do
  @moduledoc false

  @doc """
  Evaluates the contents of a file and returns the result.
  """
  @spec fetch_file!(String.t()) :: any()
  def fetch_file!(path) do
    if File.exists?(path) do
      path |> File.read!() |> Code.eval_string() |> elem(0)
    else
      raise File.Error, reason: :enoent
    end
  end

  @doc """
  Evaluates the contents of a file and returns the result.
  """
  @spec fetch_file(String.t()) :: {:ok, any()} | :error
  def fetch_file(path) do
    if File.exists?(path) do
      {:ok, path |> File.read!() |> Code.eval_string() |> elem(0)}
    else
      :error
    end
  end

  @doc """
  Returns the path to the data directory.
  """
  @spec data_path() :: String.t()
  def data_path do
    application_directory = :neo_faker |> :code.priv_dir() |> to_string()

    Path.join([application_directory, "data"])
  end
end
