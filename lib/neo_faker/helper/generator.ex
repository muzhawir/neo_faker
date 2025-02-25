defmodule NeoFaker.Helper.Generator do
  @moduledoc false

  alias NeoFaker.Helper.Locale

  def random(module, file, key, opts \\ []) do
    module
    |> fetch_data(file, opts)
    |> Map.get(key)
    |> Enum.random()
  end

  def fetch_data(module, file, opts \\ []) do
    opts |> Keyword.get(:locale, "default") |> Locale.load_persistent_term(module, file)
  end
end
