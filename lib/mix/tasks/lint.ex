defmodule Mix.Tasks.Lint do
  @shortdoc "Runs `mix format`, `mix test`, `mix dialyzer`, and `mix credo` sequentially."
  @moduledoc """
  Runs `mix format`, `mix test`, `mix dialyzer`, and `mix credo` sequentially to check code quality.

  This task is required for contributors to run before submitting a pull request (PR).
  Ensure all checks pass to maintain code consistency and correctness.
  """
  @moduledoc since: "0.5.0"

  use Mix.Task

  def run(_) do
    Mix.env(:test)

    width = terminal_width()
    separator = String.duplicate("_", width)

    Mix.Task.run("format")

    run_mix_test()
    Mix.shell().info("\n#{separator}")

    run_mix_dialyzer()
    Mix.shell().info("\n#{separator}")

    run_mix_credo()
    Mix.shell().info("\n#{separator}")
    Mix.shell().info("\n⏹️ END LINT")
  end

  defp run_mix_test do
    Mix.shell().info("\n▶️ BEGIN MIX TEST\n")
    Mix.Task.run("test")
  end

  defp run_mix_dialyzer do
    Mix.shell().info("\n▶️ BEGIN MIX DIALYZER\n")
    Mix.Task.run("dialyzer", ["--quiet-with-result"])
  end

  defp run_mix_credo do
    Mix.shell().info("\n▶️ BEGIN MIX CREDO\n")
    Mix.Task.run("credo", ["--format", "oneline"])
  end

  defp terminal_width do
    case :io.columns() do
      {:ok, width} -> width
      _ -> 80
    end
  end
end
