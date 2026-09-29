defmodule NeoFaker.Data do
  @moduledoc false

  # The single data-loading layer every domain module goes through instead of
  # touching `priv/data/**` directly. It resolves which locale applies, loads
  # the right `.exs` file, caches it in `:persistent_term`, and hands back one
  # random value.
  #
  # Cache layout (all keys are namespaced under this module):
  #
  #   {__MODULE__, locale, module, file}                -> %{key => [value]}
  #   {__MODULE__, :derived, locale, module, file, name} -> derive!/5 result
  #
  # `locale` is the *requested* locale, so a locale that falls back to
  # `:default` for a given file costs one `File.exists?/1` on the first read
  # and none afterwards.

  alias NeoFaker.Locale

  @doc """
  Returns a random value from a locale data file.

    * `module` - the domain module that owns the data, used to derive the
      data subdirectory (`NeoFaker.Person` reads `priv/data/<locale>/person/`).
    * `file` - the bare data file name, e.g. `"female_name.exs"`.
    * `key` - the map key inside that file, e.g. `"first_names"`, or a list of
      keys to draw from all of them at once. A value listed under several of
      those keys is only counted once, so it is not over-represented.
    * `opts` - only `:locale` is read. `nil` or absent means the active locale
      from `NeoFaker.Locale.get/0`.

  """
  @spec random_value(module(), String.t(), String.t() | [String.t(), ...], keyword()) :: term()
  def random_value(module, file, key, opts \\ []) do
    opts[:locale]
    |> values(module, file, key)
    |> Enum.random()
  end

  @doc """
  Returns the full cached map for a locale, module, and file.

  Tests call this directly to get the whole list a generator draws from. A
  locale that does not ship this particular file reads the `:default` copy,
  exactly like `random_value/4`. `nil` means the active locale.
  """
  @spec fetch!(Locale.t() | nil, module(), String.t()) :: %{String.t() => list()}
  def fetch!(locale, module, file) do
    validate_file_name!(file)

    locale = Locale.validate!(locale || Locale.get())

    cached({__MODULE__, locale, module, file}, fn -> load(locale, module, file) end)
  end

  defp values(locale, module, file, key) when is_binary(key) do
    locale |> fetch!(module, file) |> Map.fetch!(key)
  end

  defp values(locale, module, file, [_ | _] = keys) do
    derive!(locale, module, file, {:pool, keys}, fn data ->
      keys |> Enum.flat_map(&Map.fetch!(data, &1)) |> Enum.uniq()
    end)
  end

  @doc """
  Returns `fun` applied to the map `fetch!/3` returns, computed once and cached.

  For data a generator has to preprocess before it can draw from it, such as
  splitting a text into paragraphs. `name` identifies the derived value and
  must be unique per module and file.
  """
  @spec derive!(Locale.t() | nil, module(), String.t(), term(), (map() -> term())) :: term()
  def derive!(locale, module, file, name, fun) do
    locale = Locale.validate!(locale || Locale.get())

    cached({__MODULE__, :derived, locale, module, file, name}, fn ->
      locale |> fetch!(module, file) |> fun.()
    end)
  end

  defp cached(key, fun) do
    case :persistent_term.get(key, :undefined) do
      :undefined ->
        value = fun.()
        :persistent_term.put(key, value)
        value

      value ->
        value
    end
  end

  # A locale may ship only some of a domain's files (`:id_id` has no
  # `http/user_agent.exs`), and `:en_us` ships none at all. Any file a locale
  # does not have is read from `:default` instead.
  defp load(locale, module, file) do
    path = data_file_path(locale, module, file)

    if locale == :default or File.exists?(path) do
      read_data_file!(path)
    else
      fetch!(:default, module, file)
    end
  end

  # `priv/data/<locale>/<module dir>/<file>`, resolved through the application
  # directory so it still works inside a release, where `priv/` sits next to
  # the compiled `.beam` files rather than beside `lib/`.
  defp data_file_path(locale, module, file) do
    Application.app_dir(:neo_faker, [
      "priv",
      "data",
      Atom.to_string(locale),
      module_dir_name(module),
      file
    ])
  end

  # Every data file is a bare `%{"key" => [...]}` literal. Each list is
  # deduplicated but kept in file order; the per-call pick is uniform anyway.
  defp read_data_file!(path) do
    {data, _binding} = path |> File.read!() |> Code.eval_string([], file: path)

    Map.new(data, fn {key, values} when is_list(values) -> {key, Enum.uniq(values)} end)
  end

  # NeoFaker.Person -> "person". This derivation is the whole module-to-directory
  # mapping; it isn't configured anywhere.
  defp module_dir_name(module) do
    module |> Module.split() |> List.last() |> String.downcase()
  end

  # Only a bare `*.exs` file name is accepted. Together with
  # `NeoFaker.Locale.validate!/1` on the locale segment, this keeps every path
  # handed to `Code.eval_string/3` inside `priv/data/`.
  defp validate_file_name!(file) when is_binary(file) do
    if file != "" and Path.basename(file) == file and Path.extname(file) == ".exs" do
      file
    else
      raise ArgumentError,
            "invalid data file name #{inspect(file)}, expected a bare file name " <>
              "with an .exs extension, such as \"word.exs\""
    end
  end

  defp validate_file_name!(file) do
    raise ArgumentError, "data file name must be a string, got: #{inspect(file)}"
  end
end
