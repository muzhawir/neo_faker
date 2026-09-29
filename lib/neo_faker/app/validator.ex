defmodule NeoFaker.App.Validator do
  @moduledoc false

  # An RFC 1123 host label: 1 to 63 letters, digits, or hyphens, starting and
  # ending with a letter or digit.
  @label_regex ~r/\A[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?\z/

  @doc """
  NimbleOptions `{:custom, ...}` validator for the `:domain` option of
  `NeoFaker.App.bundle_id/1` and `NeoFaker.App.package_name/1`.

  A valid domain has at least two dot-separated RFC 1123 labels, so trailing
  dots, paths, ports, and other non-label characters are rejected.
  """
  @spec validate_domain(term()) :: {:ok, String.t()} | {:error, String.t()}
  def validate_domain(domain) when is_binary(domain) do
    labels = String.split(domain, ".")

    if length(labels) >= 2 and Enum.all?(labels, &Regex.match?(@label_regex, &1)) do
      {:ok, domain}
    else
      {:error,
       "invalid domain #{inspect(domain)}, expected at least two dot-separated labels " <>
         "made of letters, digits, and inner hyphens, such as \"example.com\""}
    end
  end

  def validate_domain(domain) do
    {:error, "expected a domain string such as \"example.com\", got: #{inspect(domain)}"}
  end
end
