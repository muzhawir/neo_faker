defmodule Mix.Tasks.UpdateVersion do
  @moduledoc false

  use Mix.Task

  @version_regex ~r/\d+\.\d+\.\d+/
  @files ["mix.exs", "README.md", "lib/pages/getting-started.md"]

  def run([new_version]) do
    current_version = get_current_version()

    with true <- Mix.shell().yes?("Update version to #{new_version}? (Y/n)"),
         :ok <- update_files(current_version, new_version) do
      Mix.shell().info("Updated version from #{current_version} to #{new_version}")
    else
      _ -> Mix.shell().error("Usage: mix update_version <new_version>")
    end
  end

  defp get_current_version do
    case File.read("mix.exs") do
      {:ok, content} -> @version_regex |> Regex.run(content) |> List.first()
      {:error, _} -> nil
    end
  end

  defp update_files(_current_version, new_version) do
    Enum.reduce_while(@files, :ok, fn file, _acc ->
      case File.read(file) do
        {:ok, content} ->
          updated_content = Regex.replace(@version_regex, content, new_version)

          case File.write(file, updated_content) do
            :ok -> {:cont, :ok}
            {:error, reason} -> {:halt, {:error, "Failed to update #{file}: #{reason}"}}
          end

        {:error, reason} ->
          {:halt, {:error, "Failed to read #{file}: #{reason}"}}
      end
    end)
  end
end
