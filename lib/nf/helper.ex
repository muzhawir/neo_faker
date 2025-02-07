defmodule Nf.Helper do
  @moduledoc """
  Helper functions.
  """
  @moduledoc since: "0.4.1"

  @doc """
  Retrieves the path to the `priv/lib` directory.

  Returns string path to `priv/lib`. This path is useful for loading dynamic files such as JSON.
  """
  def get_priv_lib_path, do: Path.join([File.cwd!(), "priv", "lib"])
end
