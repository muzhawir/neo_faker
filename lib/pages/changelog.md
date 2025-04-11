# Changelog for v0.10

## v0.10.0 (2025-04-11)

### New Generators

This release introduces several new generators.

#### `NeoFaker.Date.birthday/3`

Generates a random birthday within a specified age range.

#### `NeoFaker.Internet.user_agent/0`

Generates a random user agent string.

#### `NeoFaker.Time`

- `NeoFaker.Time.add/2` - Adds a random amount of time within a specified range.
- `NeoFaker.Time.between/3` - Generates a random time between two specified times.

### Fixes

`NeoFaker.Person.full_name/1` now returns a correctly gendered full name instead of a randomly
mixed one.
