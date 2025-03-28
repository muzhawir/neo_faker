defmodule NeoFaker.Helper.Locale do
  @moduledoc false

  @type locale_data :: map() | File.Error

  @data_path Path.join([File.cwd!(), "lib", "data"])
  @default_locale_dir Path.join([@data_path, "default"])

  @doc """
  Loads data from the persistent term or falls back to the locale file.

  Attempts to retrieve data from the persistent term. If the data is not found,
  it will be loaded from the corresponding locale file and stored in the persistent term
  for future access.

  ## Parameters

  - `locale` - The locale identifier (e.g., `"id_id"`, `"en_us"`).
  - `module` - The module associated with the locale data (e.g., `NeoFaker.App`).
  - `file` - The name of the data file within the module (e.g., `"author.exs"`).
  """
  @spec load_persistent_term(atom(), atom(), String.t()) :: locale_data()
  def load_persistent_term(locale \\ :default, module, file) do
    key = persistent_term_key(locale, module, file)

    case :persistent_term.get(key, nil) do
      nil ->
        store_persistent_term(locale, module, file)

        :persistent_term.get(key)

      term ->
        term
    end
  end

  @doc """
  Loads data from the locale file and stores it in the persistent term.

  Reads the specified data from the locale file and caches it in the persistent term
  for efficient future access.

  ## Parameters

  - `locale` - The locale identifier (e.g., `:id_id`, `:en_us`).
  - `module` - The module associated with the locale data (e.g., `NeoFaker.App`).
  - `file` - The name of the data file within the module (e.g., `"author.exs"`).
  """
  @spec store_persistent_term(atom(), atom(), String.t()) :: :ok
  def store_persistent_term(locale \\ :default, module, file) do
    data = read_locale_file!(locale, module, file)
    key = persistent_term_key(locale, module, file)

    :persistent_term.put(key, data)
  end

  @doc """
  Constructs a unique key for storing data in the persistent term.

  Generates a deterministic key based on the given `locale`, `module`, and `file`
  name. The key is used to store and retrieve data efficiently from the persistent term.
  """
  def persistent_term_key(locale \\ :default, module, file) do
    locale_string = to_string(locale)
    locale_path = Path.join([@data_path, locale_string])
    module_name = current_module(module)
    file_name = file |> String.split(".") |> List.first()

    if File.exists?(locale_path) do
      "neofaker_#{locale_string}_#{module_name}_#{file_name}"
    else
      "neofaker_default_#{module_name}_#{file_name}"
    end
  end

  @doc """
  Reads and returns data from the specified locale file.

  Reads the data from a locale-specific file and returns it as a map.
  If the file cannot be found or fails to load, an exception will be raised.
  """
  def read_locale_file!(locale \\ :default, module, file) do
    locale_path = locale_path(locale)
    current_module = current_module(module)
    file_path = Path.join([locale_path, current_module, file])

    if File.exists?(file_path) do
      file_path
      |> File.read!()
      |> Code.eval_string()
      |> elem(0)
    else
      raise File.Error, reason: :enoent
    end
  end

  @doc """
  Returns the lowercase name of the current module.

  Extracts the last part of the module name, converts it to a lowercase string, and returns it.
  """
  @spec current_module(atom()) :: String.t()
  def current_module(module) do
    module
    |> Module.split()
    |> List.last()
    |> String.downcase()
  end

  @doc """
  Returns the file path for the specified locale.

  This function constructs the path to the locale file based on the given locale. If no locale
  is provided, it defaults to the path of the default locale file.

  ## Parameters

  - `locale` - The locale identifier (e.g., `:id_id`, `:en_us`).
  """
  def locale_path(locale \\ :default) do
    locale_string = to_string(locale)
    locale_path = Path.join([@data_path, locale_string])

    if File.exists?(locale_path) do
      locale_path
    else
      @default_locale_dir
    end
  end
end
