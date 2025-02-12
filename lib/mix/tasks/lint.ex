defmodule Mix.Tasks.Lint do
  @shortdoc "Runs `mix format`, `mix test`, `mix dialyzer`, and `mix credo` sequentially."
  @moduledoc """
  Runs `mix format`, `mix test`, `mix dialyzer`, and `mix credo` sequentially to check code quality.

  This task is REQUIRED for contributors to run before submitting a Pull Request (PR).
  Ensure all checks pass to maintain code consistency and correctness.
  """
  @moduledoc since: "0.5.0"

  use Mix.Task

  @impl true
  def run(_args) do
    Mix.env(:test)
    run_lint_tasks()
  end

  defp run_lint_tasks do
    run_task("format")

    run_task("test")
    print_separator()

    run_task("dialyzer", ["--quiet-with-result"])
    print_separator()

    run_task("credo", ["--format", "oneline"])
    print_separator()

    IO.puts("END LINT")
  end

  defp print_separator do
    IO.puts("\n#{String.duplicate("_", get_terminal_width())}\n")
  end

  defp get_terminal_width do
    case :io.columns() do
      {:ok, width} -> width
      _ -> 80
    end
  end

  defp run_task(task, args \\ []) do
    IO.puts("\nBEGIN #{task}\n")
    Mix.Task.run(task, args)
  end
end
