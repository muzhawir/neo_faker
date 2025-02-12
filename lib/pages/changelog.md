# Changelog for NeoFaker v0.6

## v0.6.0 (2025-02-11)

### Added Mix Tasks to simplify contributor workflow

Added the `mix lint` task, which sequentially runs `mix format`, `mix test`, `mix dialyzer`,
and `mix credo` to ensure code quality. This makes it easier for contributors to maintain consistency.

Contributors are required to run this task before submitting a pull request (PR). Ensure all
checks pass to maintain code consistency and correctness.

### Introduced the `Person` generator

Added the `Person` module, which provides functions for generating random person-related data.

### Introduced the locale feature

NeoFaker now supports locale-based data generation, configurable in `config/config.exs`.

Locale-specific `.exs` script files are stored in `lib/data/default`, which serves as the default
directory containing the fallback file. This directory also acts as the main source for
contributors who want to add support for additional languages.
