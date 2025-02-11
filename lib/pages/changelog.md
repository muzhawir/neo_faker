# Changelog for NeoFaker v0.6.0

## Added Mix Tasks for make it easier for contributors

Added the `mix lint` task, which runs `mix format`, `mix test`, `mix dialyzer`, and `mix credo`
sequentially to check code quality. This makes it easier for contributors to maintain consistency.

This task is required for contributors to run before submitting a pull request (PR).
Ensure all checks pass to maintain code consistency and correctness.

## Introduced the locale feature

NeoFaker now generates random data based on the locale setting in `config/config.exs`.
