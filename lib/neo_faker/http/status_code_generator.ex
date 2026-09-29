defmodule NeoFaker.HTTP.StatusCodeGenerator do
  @moduledoc false

  alias NeoFaker.Data

  @groups ~w[information success redirection client_error server_error]

  @doc """
  Returns a random status line such as `"404 Not Found"` from `group`, or from every
  group when `group` is `nil`. `:simple` keeps only the numeric code.
  """
  @spec status_code(atom() | nil, :simple | :detailed) :: String.t()
  def status_code(group, type) do
    status = Data.random_value(NeoFaker.HTTP, "status_code.exs", keys(group), locale: :default)

    case type do
      :detailed -> status
      :simple -> status |> String.split(" ", parts: 2) |> hd()
    end
  end

  defp keys(nil), do: @groups
  defp keys(group), do: Atom.to_string(group)
end
