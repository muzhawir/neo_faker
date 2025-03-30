defmodule Mix.Tasks.UpdateVersion do
  @moduledoc false

  use Mix.Task

  @version_regex ~r/\d+\.\d+\.\d+/
  @files ["mix.exs", "README.md", "lib/pages/getting-started.md"]

  @spec run([String.t()]) :: :ok
  def run([new_version]) do
    case get_current_version() do
      nil -> Mix.shell().error("Failed to read current version from mix.exs")
      current_version -> process_version_update(current_version, new_version)
    end
  end

  defp process_version_update(current_version, new_version) do
    IO.puts("\nCurrent version is #{current_version}\n")

    if Mix.shell().yes?("Update version to #{new_version}? (Y/n)") do
      update_version_in_files(current_version, new_version)
    else
      Mix.shell().error("Operation canceled.")
    end
  end

  defp get_current_version do
    with {:ok, content} <- File.read("mix.exs"),
         [version] <- Regex.run(@version_regex, content) do
      version
    else
      _ -> nil
    end
  end

  defp update_version_in_files(current_version, new_version) do
    case @files
         |> Enum.map(&update_file(&1, new_version))
         |> Enum.find(&match?({:error, _}, &1)) do
      nil -> IO.puts("Updated version from #{current_version} to #{new_version}")
      {:error, reason} -> Mix.shell().error("Failed to update: #{reason}")
    end
  end

  defp update_file(file, new_version) do
    with {:ok, content} <- File.read(file),
         updated_content = Regex.replace(@version_regex, content, new_version),
         :ok <- File.write(file, updated_content) do
      :ok
    else
      {:error, reason} -> {:error, "Failed to update #{file}: #{reason}"}
    end
  end
end
