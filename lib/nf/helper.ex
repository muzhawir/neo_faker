defmodule Nf.Helper do
  @moduledoc """
  Helper functions that frequently used in other modules.
  """
  @moduledoc since: "0.4.1"

  @typedoc "Path to the `priv/lib` directory"
  @type exs_path :: list(String.t())

  @typedoc "Content of a `.exs` script file"
  @type exs_term :: map() | Code.LoadError | ArgumentError

  @doc """
  Retrieves the path to the `priv/lib` directory.

  Returns string path to `priv/lib`. This path is useful for loading dynamic files such as JSON.
  """
  @spec get_priv_lib_path() :: String.t()
  def get_priv_lib_path, do: Path.join([File.cwd!(), "priv", "lib"])

  @doc """
  Reads a `.exs` script file from the `priv/lib` directory.

  Returns map content.
  """
  @spec read_exs_file!(exs_path(), String.t()) :: exs_term()
  def read_exs_file!(path, file_name) do
    exs_path = [get_priv_lib_path()] ++ path ++ [file_name]

    exs_path
    |> Path.join()
    |> Code.eval_file()
    |> elem(0)
  end
end
