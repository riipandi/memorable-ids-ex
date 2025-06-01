defmodule MemorableIds.Dictionary do
  @moduledoc """
  Dictionary of words for memorable ID generation

  Contains collections of English words categorized by part of speech.
  Used to generate human-readable, memorable identifiers.
  """

  @doc """
  English adjectives (78 total)
  Descriptive words that modify nouns
  """
  def adjectives do
    [
      "cute",
      "dapper",
      "large",
      "small",
      "long",
      "short",
      "thick",
      "narrow",
      "deep",
      "flat",
      "whole",
      "low",
      "high",
      "near",
      "far",
      "fast",
      "quick",
      "slow",
      "early",
      "late",
      "bright",
      "dark",
      "cloudy",
      "warm",
      "cool",
      "cold",
      "windy",
      "noisy",
      "loud",
      "quiet",
      "dry",
      "clear",
      "hard",
      "soft",
      "heavy",
      "light",
      "strong",
      "weak",
      "tidy",
      "clean",
      "dirty",
      "empty",
      "full",
      "close",
      "thirsty",
      "hungry",
      "fat",
      "old",
      "fresh",
      "dead",
      "healthy",
      "sweet",
      "sour",
      "bitter",
      "salty",
      "good",
      "bad",
      "great",
      "important",
      "useful",
      "expensive",
      "cheap",
      "free",
      "difficult",
      "able",
      "rich",
      "afraid",
      "brave",
      "fine",
      "sad",
      "proud",
      "comfortable",
      "happy",
      "clever",
      "interesting",
      "famous",
      "exciting",
      "funny",
      "kind",
      "polite",
      "fair"
    ]
  end

  @doc """
  English nouns - animals and common objects (68 total)
  Concrete things, animals, and objects
  """
  def nouns do
    [
      "rabbit",
      "badger",
      "fox",
      "chicken",
      "bat",
      "deer",
      "snake",
      "hare",
      "hedgehog",
      "platypus",
      "mole",
      "mouse",
      "otter",
      "rat",
      "squirrel",
      "stoat",
      "weasel",
      "crow",
      "dove",
      "duck",
      "goose",
      "hawk",
      "heron",
      "kingfisher",
      "owl",
      "peacock",
      "pheasant",
      "pigeon",
      "robin",
      "rook",
      "sparrow",
      "starling",
      "swan",
      "ant",
      "bee",
      "butterfly",
      "dragonfly",
      "fly",
      "moth",
      "spider",
      "pike",
      "salmon",
      "trout",
      "frog",
      "newt",
      "toad",
      "crab",
      "lobster",
      "clam",
      "cockle",
      "mussel",
      "oyster",
      "snail",
      "cow",
      "dog",
      "donkey",
      "goat",
      "horse",
      "pig",
      "sheep",
      "ferret",
      "gerbil",
      "guinea-pig",
      "parrot",
      "book",
      "table",
      "chair",
      "lamp"
    ]
  end

  @doc """
  English verbs - present tense (40 total)
  Action words in present tense form
  """
  def verbs do
    [
      "sing",
      "play",
      "knit",
      "flounder",
      "dance",
      "listen",
      "run",
      "talk",
      "cuddle",
      "sit",
      "kiss",
      "hug",
      "whimper",
      "hide",
      "fight",
      "whisper",
      "cry",
      "snuggle",
      "walk",
      "drive",
      "loiter",
      "feel",
      "jump",
      "hop",
      "go",
      "marry",
      "engage",
      "sleep",
      "eat",
      "drink",
      "read",
      "write",
      "swim",
      "fly",
      "climb",
      "build",
      "create",
      "explore",
      "discover",
      "learn"
    ]
  end

  @doc """
  English adverbs (27 total)
  Words that modify verbs, adjectives, or other adverbs
  """
  def adverbs do
    [
      "jovially",
      "merrily",
      "cordially",
      "carefully",
      "correctly",
      "eagerly",
      "easily",
      "fast",
      "loudly",
      "patiently",
      "quickly",
      "quietly",
      "slowly",
      "gently",
      "firmly",
      "softly",
      "boldly",
      "bravely",
      "calmly",
      "clearly",
      "closely",
      "deeply",
      "directly",
      "exactly",
      "fairly",
      "freely",
      "fully"
    ]
  end

  @doc """
  English prepositions (26 total)
  Words that show relationships between other words
  """
  def prepositions do
    [
      "in",
      "on",
      "at",
      "by",
      "for",
      "with",
      "from",
      "to",
      "of",
      "about",
      "under",
      "over",
      "through",
      "between",
      "among",
      "during",
      "before",
      "after",
      "above",
      "below",
      "beside",
      "behind",
      "beyond",
      "within",
      "without",
      "across"
    ]
  end

  @doc """
  Dictionary statistics for combination calculations
  """
  def stats do
    %{
      adjectives: length(adjectives()),
      nouns: length(nouns()),
      verbs: length(verbs()),
      adverbs: length(adverbs()),
      prepositions: length(prepositions())
    }
  end

  @doc """
  Get all word collections grouped by type

  ## Examples

      iex> dictionary = MemorableIds.Dictionary.all()
      iex> is_list(dictionary.adjectives)
      true
      iex> is_map(dictionary.stats)
      true
  """
  def all do
    %{
      adjectives: adjectives(),
      nouns: nouns(),
      verbs: verbs(),
      adverbs: adverbs(),
      prepositions: prepositions(),
      stats: stats()
    }
  end

  @doc """
  Get a random word from specified category

  ## Examples

      iex> word = MemorableIds.Dictionary.random_word(:adjectives)
      iex> word in MemorableIds.Dictionary.adjectives()
      true
  """
  def random_word(category)
      when category in [:adjectives, :nouns, :verbs, :adverbs, :prepositions] do
    words = apply(__MODULE__, category, [])
    Enum.random(words)
  end
end
