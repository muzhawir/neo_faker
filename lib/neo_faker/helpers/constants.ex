defmodule NeoFaker.Helpers.Constants do
  @moduledoc """
  Centralizes constant values used across NeoFaker modules.

  This module provides a single source of truth for magic values, file names,
  regex patterns, and other constants to improve maintainability.
  """
  @moduledoc since: "0.14.0"

  # Data file names
  @city_file "city.exs"
  @country_file "country.exs"
  @gender_file "gender.exs"
  @name_affixes_file "name_affixes.exs"
  @lorem_ipsum_file "lorem_ipsum.exs"
  @meditations_file "meditations.exs"
  @time_zone_file "time_zone.exs"
  @word_file "word.exs"

  # Regex patterns
  @new_line_regexp ~r/(?<!\n)\n(?!\n)/
  @punctuation_regexp ~r/[[:punct:]]/
  @sentence_delimiter_regexp ~r/(?<=[.!?])\s+/

  # Character sets
  @alphabet_lower ~w[a b c d e f g h i j k l m n o p q r s t u v w x y z]
  @alphabet_upper ~w[A B C D E F G H I J K L M N O P Q R S T U V W X Y Z]
  @digits ~w[0 1 2 3 4 5 6 7 8 9]

  # Default values
  @default_locale :default
  @default_date_range -365..365
  @default_time_range -24..24
  @default_age_min 18
  @default_age_max 65
  @default_building_number_range 1..100
  @default_coordinate_precision 6
  @default_username_word_count 2
  @default_domain_word_count 1
  @default_number_range 1..1000
  @default_character_count 11

  # Data file accessors
  @doc "Returns the city data file name"
  @spec city_file() :: String.t()
  def city_file, do: @city_file

  @doc "Returns the country data file name"
  @spec country_file() :: String.t()
  def country_file, do: @country_file

  @doc "Returns the gender data file name"
  @spec gender_file() :: String.t()
  def gender_file, do: @gender_file

  @doc "Returns the name affixes data file name"
  @spec name_affixes_file() :: String.t()
  def name_affixes_file, do: @name_affixes_file

  @doc "Returns the lorem ipsum data file name"
  @spec lorem_ipsum_file() :: String.t()
  def lorem_ipsum_file, do: @lorem_ipsum_file

  @doc "Returns the meditations data file name"
  @spec meditations_file() :: String.t()
  def meditations_file, do: @meditations_file

  @doc "Returns the time zone data file name"
  @spec time_zone_file() :: String.t()
  def time_zone_file, do: @time_zone_file

  @doc "Returns the word data file name"
  @spec word_file() :: String.t()
  def word_file, do: @word_file

  # Regex pattern accessors
  @doc "Returns the new line regex pattern"
  @spec new_line_regexp() :: Regex.t()
  def new_line_regexp, do: @new_line_regexp

  @doc "Returns the punctuation regex pattern"
  @spec punctuation_regexp() :: Regex.t()
  def punctuation_regexp, do: @punctuation_regexp

  @doc "Returns the sentence delimiter regex pattern"
  @spec sentence_delimiter_regexp() :: Regex.t()
  def sentence_delimiter_regexp, do: @sentence_delimiter_regexp

  # Character set accessors
  @doc "Returns the lowercase alphabet as a list of characters"
  @spec alphabet_lower() :: list(String.t())
  def alphabet_lower, do: Enum.shuffle(@alphabet_lower)

  @doc "Returns the uppercase alphabet as a list of characters"
  @spec alphabet_upper() :: list(String.t())
  def alphabet_upper, do: Enum.shuffle(@alphabet_upper)

  @doc "Returns both lowercase and uppercase alphabet as a list of characters"
  @spec alphabet() :: list(String.t())
  def alphabet, do: Enum.shuffle(@alphabet_lower ++ @alphabet_upper)

  @doc "Returns digits 0-9 as a list of strings"
  @spec digits() :: list(String.t())
  def digits, do: Enum.shuffle(@digits)

  @doc "Returns alphanumeric characters as a list of strings"
  @spec alphanumeric() :: list(String.t())
  def alphanumeric, do: Enum.shuffle(@alphabet_lower ++ @alphabet_upper ++ @digits)

  # Default value accessors
  @doc "Returns the default locale"
  @spec default_locale() :: atom()
  def default_locale, do: @default_locale

  @doc "Returns the default date range"
  @spec default_date_range() :: Range.t()
  def default_date_range, do: @default_date_range

  @doc "Returns the default time range"
  @spec default_time_range() :: Range.t()
  def default_time_range, do: @default_time_range

  @doc "Returns the default minimum age"
  @spec default_age_min() :: non_neg_integer()
  def default_age_min, do: @default_age_min

  @doc "Returns the default maximum age"
  @spec default_age_max() :: non_neg_integer()
  def default_age_max, do: @default_age_max

  @doc "Returns the default building number range"
  @spec default_building_number_range() :: Range.t()
  def default_building_number_range, do: @default_building_number_range

  @doc "Returns the default coordinate precision"
  @spec default_coordinate_precision() :: non_neg_integer()
  def default_coordinate_precision, do: @default_coordinate_precision

  @doc "Returns the default username word count"
  @spec default_username_word_count() :: non_neg_integer()
  def default_username_word_count, do: @default_username_word_count

  @doc "Returns the default domain word count"
  @spec default_domain_word_count() :: non_neg_integer()
  def default_domain_word_count, do: @default_domain_word_count

  @doc "Returns the default number range"
  @spec default_number_range() :: Range.t()
  def default_number_range, do: @default_number_range

  @doc "Returns the default character count"
  @spec default_character_count() :: non_neg_integer()
  def default_character_count, do: @default_character_count

  # Valid option values
  @doc "Returns valid format options for date/time"
  @spec valid_datetime_formats() :: list(atom())
  def valid_datetime_formats, do: [:struct, :iso8601]

  @doc "Returns valid format options for colors"
  @spec valid_color_formats() :: list(atom())
  def valid_color_formats, do: [nil, :w3c]

  @doc "Returns valid format options for hexadecimal colors"
  @spec valid_hex_formats() :: list(atom())
  def valid_hex_formats, do: [:three_digit, :four_digit, :six_digit, :eight_digit]

  @doc "Returns valid type options for numbers"
  @spec valid_number_types() :: list(atom())
  def valid_number_types, do: [:string, :integer]

  @doc "Returns valid sex options for person names"
  @spec valid_sex_options() :: list(atom())
  def valid_sex_options, do: [:unisex, :male, :female]

  @doc "Returns valid text source options"
  @spec valid_text_sources() :: list(atom())
  def valid_text_sources, do: [:lorem, :meditations]

  @doc "Returns valid username joiner options"
  @spec valid_username_joiners() :: list(atom())
  def valid_username_joiners, do: [:all, :dot, :underscore, :dash]

  @doc "Returns valid username type options"
  @spec valid_username_types() :: list(atom())
  def valid_username_types, do: [:person, :word]

  @doc "Returns valid domain type options"
  @spec valid_domain_types() :: list(atom())
  def valid_domain_types, do: [:random, :popular, :custom]

  @doc "Returns valid popular domain type options"
  @spec valid_popular_domain_types() :: list(atom())
  def valid_popular_domain_types, do: [:all, :ecommerce, :email, :search, :social]

  @doc "Returns valid TLD type options"
  @spec valid_tld_types() :: list(atom())
  def valid_tld_types, do: [:all_except_safe, :all, :safe, :generic, :sponsored, :country_code]

  @doc "Returns valid character type options"
  @spec valid_character_types() :: list(atom())
  def valid_character_types, do: [:alphabet_lower, :alphabet_upper, :alphabet, :digit]

  @doc "Returns valid emoji category options"
  @spec valid_emoji_categories() :: list(atom())
  def valid_emoji_categories do
    [
      :all,
      :activities,
      :animals_and_nature,
      :food_and_drink,
      :objects,
      :people_and_body,
      :smileys_and_emotion,
      :symbols,
      :travel_and_places
    ]
  end

  @doc "Returns valid color keyword category options"
  @spec valid_color_keyword_categories() :: list(atom())
  def valid_color_keyword_categories, do: [:all, :basic, :extended]

  @doc "Returns valid time unit options"
  @spec valid_time_units() :: list(atom())
  def valid_time_units, do: [:hour, :minute, :second]

  @doc "Returns valid coordinate type options"
  @spec valid_coordinate_types() :: list(atom())
  def valid_coordinate_types, do: [:full, :latitude, :longitude]
end
