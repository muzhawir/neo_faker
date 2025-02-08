defmodule Nf.Helper do
  @moduledoc """
  Helper functions.
  """
  @moduledoc since: "0.4.1"

  @type json_path :: list(String.t())
  @type json_term :: term() | File.Error | Jason.DecodeError

  @doc """
  Retrieves the path to the `priv/lib` directory.

  Returns string path to `priv/lib`. This path is useful for loading dynamic files such as JSON.
  """
  @spec get_priv_lib_path() :: String.t()
  def get_priv_lib_path, do: Path.join([File.cwd!(), "priv", "lib"])

  @doc """
  Reads a JSON file from the `priv/lib` directory.

  Returns a decoded JSON term.
  """
  @spec read_json_file(json_path(), String.t()) :: json_term()
  def read_json_file(path, file_name) when is_list(path) do
    json_path = path ++ [file_name]

    get_priv_lib_path()
    |> Path.join(json_path)
    |> File.read!()
    |> JSON.decode!()
  end
end
