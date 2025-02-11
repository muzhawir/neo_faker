defmodule Mix.Tasks.UpdateVersion do
  @moduledoc false

  use Mix.Task

  @version_regex ~r/\d+\.\d+\.\d+/
  @files [
    "config/config.exs",
    "README.md",
    "lib/pages/getting-started.md"
  ]

  def run(args) do
    with [new_version] <- args,
         current_version when not is_nil(current_version) <- get_current_version(),
         true <- Mix.shell().yes?("Do you want to update version to #{new_version}? (Y/n)"),
         :ok <- update_version_in_files(current_version, new_version) do
      Mix.shell().info("NeoFaker version updated from #{current_version} to #{new_version}")
    else
      [] ->
        Mix.shell().error("Usage: mix update_version <new_version>")

      nil ->
        Mix.shell().error("Error: Unable to detect current version.")

      false ->
        Mix.shell().info("Update canceled.")

      {:error, reason} ->
        Mix.shell().error("Error: cannot update. Reason: #{reason}")
    end
  end

  defp get_current_version do
    "README.md"
    |> File.read()
    |> case do
      {:ok, content} -> @version_regex |> Regex.run(content) |> List.first()
      {:error, _} -> nil
    end
  end

  defp update_version_in_files(current_version, new_version) do
    Enum.reduce_while(@files, :ok, fn file, _acc ->
      case update_file(file, current_version, new_version) do
        :ok -> {:cont, :ok}
        {:error, reason} -> {:halt, {:error, "Failed to update #{file}: #{reason}"}}
      end
    end)
  end

  defp update_file(file, current_version, new_version) do
    with {:ok, content} <- File.read(file),
         updated_content = Regex.replace(@version_regex, content, new_version) do
      File.write(file, updated_content)
    end
  end
end
