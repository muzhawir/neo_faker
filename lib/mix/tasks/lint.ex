defmodule Mix.Tasks.Lint do
  @moduledoc false

  use Mix.Task

  def run(_) do
    Mix.env(:test)

    width = terminal_width()
    separator = String.duplicate("-", width)

    run_mix_format()
    Mix.shell().info("\n#{separator}\n")

    run_mix_test()
    Mix.shell().info("\n#{separator}\n")

    run_mix_dialyzer()
    Mix.shell().info("\n#{separator}\n")

    run_mix_credo()
    Mix.shell().info("\n#{separator}\n")
  end

  defp run_mix_format do
    Mix.Task.reenable("format")
    Mix.Task.run("format")
  end

  defp run_mix_test do
    Mix.Task.reenable("test")
    Mix.Task.run("test")
  end

  defp run_mix_dialyzer do
    Mix.Task.reenable("dialyzer")
    Mix.Task.run("dialyzer", ["--quiet-with-result"])
  end

  defp run_mix_credo do
    Mix.Task.reenable("credo")
    Mix.Task.run("credo", ["--format", "oneline"])
    Mix.shell().info("Mix Credo finished")
  end

  defp terminal_width do
    case :io.columns() do
      {:ok, width} -> width
      _ -> 80
    end
  end
end
