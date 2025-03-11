# Changelog for v0.8

## v0.8.0 (2025-03-08)

### New Generator Functions

This release introduces several new generator functions.

#### `NeoFaker.Color`

The `NeoFaker.Color` module provides functions for generating random colors, including:

- `NeoFaker.Color.cmyk/1`
- `NeoFaker.Color.hex/1`
- `NeoFaker.Color.hsl/1`
- `NeoFaker.Color.keyword/1`
- `NeoFaker.Color.rgb/1`
- `NeoFaker.Color.rgba/1`

#### `NeoFaker.Lorem`

The `NeoFaker.Lorem` module offers functions for generating random text using the Lorem Ipsum
generator, including:

- `NeoFaker.Lorem.paragraph/1`
- `NeoFaker.Lorem.sentence/1`
- `NeoFaker.Lorem.word/1`

#### `NeoFaker.Number`

The `NeoFaker.Number` module provides functions for generating random numbers, including:

- `NeoFaker.Number.between/1`
- `NeoFaker.Number.digit/0`
- `NeoFaker.Number.float/1`

#### `NeoFaker.Text`

The `NeoFaker.Text` module includes functions for generating random text, such as:

- `NeoFaker.Text.character/1`
- `NeoFaker.Text.characters/1`
- `NeoFaker.Text.emoji/1`
