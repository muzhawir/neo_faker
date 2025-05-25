defmodule Mix.Tasks.Check.Code do
  @shortdoc "Runs format, test, dialyzer, and credo with informative output."

  @moduledoc """
  Runs a series of code quality checks: formatting, testing, static analysis, and linting.

  This Mix task executes the following commands sequentially:

    * `mix format` - Ensures code is properly formatted.
    * `mix test` - Runs the test suite to verify correctness.
    * `mix dialyzer` - Performs static analysis to detect type errors.
    * `mix credo` - Checks for code style and best practices.

  ## Requirements

  Contributors **MUST** run this task before submitting a Pull Request (PR).
  All checks must pass to maintain code quality, consistency, and correctness.

  ## Usage

      mix check.code

  ## Notes

    - If any command fails, the process will stop, and the corresponding error must be resolved.
    - Running `mix dialyzer` may take longer on the first run due to PLT building.
  """

  use Mix.Task

  @impl true
  def run(_args) do
    Mix.env(:test)
    IO.puts(IO.ANSI.format([:cyan, "\n==> Starting code quality checks...\n"]))

    run_lint_tasks()
  end

  defp run_lint_tasks do
    run_task("format", [], "Checking code formatting")
    run_task("test", [], "Running tests")
    print_separator()

    run_task("dialyzer", [], "Running static analysis (dialyzer)")
    print_separator()

    run_task("credo", ["--format", "oneline"], "Running code style checks (credo)")
    print_separator()

    IO.puts(IO.ANSI.format([:green, "All checks completed successfully!\n"]))
  end

  defp print_separator do
    IO.puts(
      IO.ANSI.format([:yellow, "\n" <> String.duplicate("_", get_terminal_width()) <> "\n"])
    )
  end

  defp get_terminal_width do
    case :io.columns() do
      {:ok, width} when width > 20 -> min(width, 120)
      _ -> 80
    end
  end

  defp run_task("credo", args, description) do
    command = ["credo" | args]
    IO.puts(IO.ANSI.format([:blue, "\n==> #{description} (mix #{Enum.join(command, " ")})\n"]))

    {_output, status} = System.cmd("mix", command, into: IO.stream(:stdio, :line))

    if status == 0 do
      IO.puts(IO.ANSI.format([:green, "✓ #{description} passed\n"]))
    else
      IO.puts(
        IO.ANSI.format([
          :red,
          "✗ #{description} failed. Stopping.\n",
          :yellow,
          "You can rerun this step with: ",
          :reset,
          "mix #{Enum.join(command, " ")}\n"
        ])
      )

      IO.puts(IO.ANSI.format([:red, "Please fix the issues above before continuing.\n"]))

      Mix.raise("#{description} failed. Please fix the issues above before continuing.")
    end
  end

  defp run_task(task, args, description) do
    command = "mix #{task} #{Enum.join(args, " ")}"
    IO.puts(IO.ANSI.format([:blue, "\n==> #{description} (#{command})\n"]))

    case Mix.Task.run(task, args) do
      result when result in [:ok, :noop] ->
        IO.puts(IO.ANSI.format([:green, "✓ #{description} passed\n"]))

      _ ->
        IO.puts(
          IO.ANSI.format([
            :red,
            "✗ #{description} failed. Stopping.\n",
            :yellow,
            "You can rerun this step with: ",
            :reset,
            command,
            "\n"
          ])
        )

        IO.puts(IO.ANSI.format([:red, "Please fix the issues above before continuing.\n"]))

        Mix.raise("#{description} failed. Please fix the issues above before continuing.")
    end
  end
end
