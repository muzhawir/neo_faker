defmodule NeoFaker.Data do
  @moduledoc false

  # The single data-loading layer every domain module goes through instead of
  # touching `priv/data/**` directly. It resolves which locale applies, loads
  # the right `.exs` file, caches it in `:persistent_term`, and hands back one
  # random value. `@moduledoc false` hides this from ExDoc since it's plumbing,
  # not something a NeoFaker user should ever call directly, but its functions
  # stay real `def`s (not `defp`) because every domain module across the
  # `NeoFaker.*` namespace needs to call into it.

  alias NeoFaker.Locale

  @doc """
  Returns a random value from the specified locale data file.

  This is what a domain module's public function calls to get one value out of
  its data file.

    * `module` - the calling module, used to derive the data subdirectory
      (e.g. `NeoFaker.Person` reads from `priv/data/<locale>/person/`).
    * `file` - the bare data file name, e.g. `"first_names.exs"`. Must pass
      `validate_file_name!/1`.
    * `key` - the map key to read inside that file, e.g. `"first_names"`.
    * `opts` - forwarded from the caller; only `:locale` is read here. When it
      is absent, the active locale from `NeoFaker.Locale.get/0` is used.
  """
  @spec random_value(atom(), String.t(), String.t(), keyword()) :: any()
  def random_value(module, file, key, opts \\ []) do
    validate_file_name!(file)

    opts[:locale]
    |> load(module, file)
    |> Map.fetch!(key)
    |> Enum.random()
  end

  @doc """
  Returns the full cached map for a given locale, module, and file.

  `random_value/4` picks one value out of this; tests call it directly to get
  the whole list a domain function draws from, so they can assert a generated
  value came from the real data set. Same per-file `:default` fallback as
  `random_value/4`: a locale that doesn't have this specific file reads the
  `:default` copy instead.
  """
  @spec fetch!(atom(), atom(), String.t()) :: map()
  def fetch!(locale, module, file) do
    validate_file_name!(file)
    load(locale, module, file)
  end

  # ---------------------------------------------------------------------------
  # Loading and caching
  # ---------------------------------------------------------------------------

  # Resolves the locale (per-file, falling back to `:default`), then returns the
  # file's cached map, reading and deduplicating it from disk on the first call
  # for that locale/module/file triple. `nil` means "no explicit locale given",
  # so the active locale from `NeoFaker.Locale` is used.
  @spec load(atom() | nil, atom(), String.t()) :: map()
  defp load(locale, module, file) do
    locale = resolve_locale(locale || Locale.get(), module, file)
    key = {__MODULE__, locale, module, Path.rootname(file)}

    case :persistent_term.get(key, nil) do
      nil ->
        data = read_data_file!(data_file_path(locale, module, file))
        :persistent_term.put(key, data)
        data

      data ->
        data
    end
  end

  # A locale can be unregistered, or registered but missing this one file (e.g.
  # `:id_id` has no `http/user_agent.exs`). Either way the read falls back to
  # `:default`, the baseline set `:en_us` already uses. Setting an unsupported
  # locale is rejected upfront by `NeoFaker.Locale.set/1`; this is the softer
  # per-call, per-file net.
  @spec resolve_locale(atom(), atom(), String.t()) :: atom()
  defp resolve_locale(locale, module, file) do
    if File.exists?(data_file_path(locale, module, file)), do: locale, else: :default
  end

  # `priv/data/<locale>/<module dir>/<file>`. Goes through `:code.priv_dir/1`
  # rather than a path relative to this source file, so it still resolves once
  # the app is compiled into a release, where `priv/` moves next to the compiled
  # `.beam` files instead of staying beside `lib/`.
  @spec data_file_path(atom(), atom(), String.t()) :: String.t()
  defp data_file_path(locale, module, file) do
    priv_data = :neo_faker |> :code.priv_dir() |> to_string() |> Path.join("data")

    Path.join([priv_data, Atom.to_string(locale), module_dir_name(module), file])
  end

  # Every locale data file is a bare `%{...}` map literal, so evaluating it is
  # enough; there's no need for a real `Code` loader. Each list value is
  # deduplicated but kept in file order (the per-call pick is `Enum.random/1`,
  # which is uniform regardless of order).
  @spec read_data_file!(String.t()) :: map()
  defp read_data_file!(path) do
    path
    |> File.read!()
    |> Code.eval_string([], __ENV__)
    |> elem(0)
    |> Map.new(fn {key, list} -> {key, Enum.uniq(list)} end)
  end

  # NeoFaker.Person -> "person": every domain's data lives under its own last
  # name segment, lowercased. This derivation is the whole module-to-directory
  # mapping; it isn't configured anywhere.
  @spec module_dir_name(atom()) :: String.t()
  defp module_dir_name(module) do
    module |> Module.split() |> List.last() |> String.downcase()
  end

  # Validates that `file` is a bare filename (no directory component) with a
  # `.exs` extension. Raises `ArgumentError` on any other value, preventing
  # path traversal and arbitrary-file evaluation via `Code.eval_string/3`.
  @spec validate_file_name!(String.t()) :: String.t()
  defp validate_file_name!(file) when is_binary(file) do
    if file != "" and Path.basename(file) == file and Path.extname(file) == ".exs" do
      file
    else
      raise ArgumentError,
            "invalid data file name #{inspect(file)}. " <>
              "Expected a bare filename with a .exs extension, e.g. \"word.exs\"."
    end
  end

  defp validate_file_name!(file) do
    raise ArgumentError,
          "data file name must be a string, got: #{inspect(file)}"
  end
end
