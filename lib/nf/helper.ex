defmodule Nf.Helper do
  @moduledoc """
  Provides utility functions commonly used across modules.
  """
  @moduledoc since: "0.4.1"

  @typedoc "Path to the `priv/lib` directory"
  @type exs_path :: list(String.t())

  @doc """
  Returns the absolute path to the `priv/lib` directory.

  This path is useful for loading dynamic files, such as JSON.
  """
  @spec get_priv_lib_path() :: String.t()
  def get_priv_lib_path, do: Path.join([File.cwd!(), "priv", "lib"])

  @doc """
  Reads an `.exs` script file from the `priv/lib` directory and returns its contents as a map.
  """
  @spec read_exs_file!(exs_path(), String.t()) :: map()
  def read_exs_file!(path, file_name) do
    exs_path = [get_priv_lib_path()] ++ path ++ [file_name]

    exs_path
    |> Path.join()
    |> Code.eval_file()
    |> elem(0)
  end
end
