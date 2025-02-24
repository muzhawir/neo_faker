defmodule NeoFaker.Helper.Locale do
  @moduledoc false

  @type locale :: String.t() | nil
  @type locale_data :: map() | File.Error

  @data_path Path.join([File.cwd!(), "lib", "data"])

  @doc """
  Loads data from the persistent term.

  Loads data from the persistent term, if the data is not found in the persistent term, it will be
  loaded from the locale file first.
  """
  @spec load_persistent_term(locale(), atom(), String.t()) :: any()
  def load_persistent_term(locale \\ nil, module, file) do
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
  Loads data from the locale file and stores it in persistent term.

  Reads the specified data from the locale file and stores it in the persistent term.
  """
  @spec store_persistent_term(locale(), atom(), String.t()) :: :ok
  def store_persistent_term(locale \\ nil, module, file) do
    data = read_locale_file!(locale, module, file)
    key = persistent_term_key(locale, module, file)

    :persistent_term.put(key, data)
  end

  @doc """
  Creates a key for storing data in persistent term.

  Creates a key for storing data in persistent term based on the locale, module, and file name.
  """
  @spec persistent_term_key(locale(), atom(), String.t()) :: String.t()
  def persistent_term_key(locale \\ nil, module, file) do
    locale_setting = locale || Application.get_env(:neo_faker, :locale)
    file_path = Path.join([@data_path, locale_setting])
    module_name = current_module(module)
    file_name = file |> String.split(".") |> List.first()

    if File.exists?(file_path) do
      "neofaker_#{locale_setting}_#{module_name}_#{file_name}"
    else
      "neofaker_default_#{module_name}_#{file_name}"
    end
  end

  @doc """
  Reads data from the locale file.

  Reads the specified data from the locale file and returns it as a map.
  """
  @spec read_locale_file!(locale(), atom(), String.t()) :: locale_data()
  def read_locale_file!(locale \\ nil, module, file) do
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
  Returns the name of the current module in lowercase.

  Splits the module name into parts and returns the last part in lowercase string.
  """
  @spec current_module(atom()) :: String.t()
  def current_module(module) do
    module
    |> Module.split()
    |> List.last()
    |> String.downcase()
  end

  @doc """
  Returns the path to the locale file.

  If the locale is provided, it returns the path to the locale file. Otherwise, it returns the path
  to the default locale file.
  """
  @spec locale_path(locale()) :: String.t()
  def locale_path(locale \\ nil) do
    locale_setting = locale || Application.get_env(:neo_faker, :locale)
    file_path = Path.join([@data_path, locale_setting])

    if File.exists?(file_path) do
      file_path
    else
      Path.join([@data_path, "default"])
    end
  end
end
