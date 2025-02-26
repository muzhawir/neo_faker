defmodule Mix.Tasks.CheckCode do
  @shortdoc "Runs `mix format`, `mix test`, `mix dialyzer`, and `mix credo` sequentially."

  @moduledoc """
  Runs a series of code quality checks, including formatting, testing, static analysis, and linting.

  This Mix task executes the following commands sequentially:

  - `mix format`   - Ensures code is properly formatted.
  - `mix test`     - Runs the test suite to verify correctness.
  - `mix dialyzer` - Performs static analysis to detect type errors.
  - `mix credo`    - Checks for code style and best practices.

  ## Usage

      mix check_code

  ## Requirements

  Contributors **MUST** run this task before submitting a Pull Request (PR).
  Ensure that all checks pass to maintain code quality, consistency, and correctness.

  ## Notes

  - If any command fails, the process will stop, and the corresponding error must be resolved.
  - Running `mix dialyzer` may take longer on the first run due to PLT (Persistent Lookup Table)
  building.

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

    run_task("dialyzer")

    print_separator()

    run_task("credo", ["--format", "oneline"])

    print_separator()

    IO.puts("END check_code\n")
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
