defmodule NeoFaker.App.Validator do
  @moduledoc false

  # RFC 1123 label: starts and ends with alphanumeric, allows internal hyphens,
  # 1–63 characters. A valid domain requires at least two such labels (SLD + TLD)
  # and no trailing dot, path separator, port, or other non-label character.
  @domain_label_regex ~r/^[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?$/

  @doc """
  Validates the `:domain` option for `bundle_id/1` and `package_name/1`.

  Returns `{:ok, domain}` if valid, `{:error, message}` otherwise. Used as a `NimbleOptions`
  custom validator. A valid domain must consist of at least two dot-separated labels, each
  matching the RFC 1123 format: starts and ends with an alphanumeric character, contains only
  letters, digits, and hyphens, and is between 1 and 63 characters long. Values with trailing
  dots, path separators (`/`), port suffixes (`:`), or any other non-label characters are
  rejected.
  """
  @spec validate_domain(term()) :: {:ok, String.t()} | {:error, String.t()}
  def validate_domain(domain) when is_binary(domain) do
    labels = String.split(domain, ".", trim: false)

    valid =
      length(labels) >= 2 and
        not String.ends_with?(domain, ".") and
        Enum.all?(labels, &Regex.match?(@domain_label_regex, &1))

    if valid do
      {:ok, domain}
    else
      {:error,
       "Invalid domain #{inspect(domain)}. Expected a valid domain with at least two " <>
         "dot-separated labels (e.g. \"example.com\"). Each label must start and end " <>
         "with an alphanumeric character and contain only letters, digits, and hyphens."}
    end
  end

  def validate_domain(domain) do
    {:error, "Invalid domain #{inspect(domain)}. Expected a binary string, e.g. \"example.com\"."}
  end
end
