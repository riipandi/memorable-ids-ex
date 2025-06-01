defmodule MemorableIds.DictionaryTest do
  use ExUnit.Case
  doctest MemorableIds.Dictionary

  alias MemorableIds.Dictionary

  describe "word lists" do
    test "should return correct adjectives list" do
      adjectives = Dictionary.adjectives()

      assert is_list(adjectives)
      assert length(adjectives) == 78
      assert "cute" in adjectives
      assert "dangerous" in adjectives
    end

    test "should return correct nouns list" do
      nouns = Dictionary.nouns()

      assert is_list(nouns)
      assert length(nouns) == 68
      assert "rabbit" in nouns
      assert "door" in nouns
    end

    test "should return correct verbs list" do
      verbs = Dictionary.verbs()

      assert is_list(verbs)
      assert length(verbs) == 40
      assert "sing" in verbs
      assert "learn" in verbs
    end

    test "should return correct adverbs list" do
      adverbs = Dictionary.adverbs()

      assert is_list(adverbs)
      assert length(adverbs) == 27
      assert "jovially" in adverbs
      assert "fully" in adverbs
    end

    test "should return correct prepositions list" do
      prepositions = Dictionary.prepositions()

      assert is_list(prepositions)
      assert length(prepositions) == 26
      assert "in" in prepositions
      assert "across" in prepositions
    end
  end

  describe "stats/0" do
    test "should return correct statistics" do
      stats = Dictionary.stats()

      assert is_map(stats)
      assert stats.adjectives == 78
      assert stats.nouns == 68
      assert stats.verbs == 40
      assert stats.adverbs == 27
      assert stats.prepositions == 26
    end

    test "should match actual word list lengths" do
      stats = Dictionary.stats()

      assert stats.adjectives == length(Dictionary.adjectives())
      assert stats.nouns == length(Dictionary.nouns())
      assert stats.verbs == length(Dictionary.verbs())
      assert stats.adverbs == length(Dictionary.adverbs())
      assert stats.prepositions == length(Dictionary.prepositions())
    end
  end

  describe "all/0" do
    test "should return all dictionary data" do
      all_data = Dictionary.all()

      assert is_map(all_data)
      assert is_list(all_data.adjectives)
      assert is_list(all_data.nouns)
      assert is_list(all_data.verbs)
      assert is_list(all_data.adverbs)
      assert is_list(all_data.prepositions)
      assert is_map(all_data.stats)
    end

    test "should contain correct word counts in all data" do
      all_data = Dictionary.all()

      assert length(all_data.adjectives) == 78
      assert length(all_data.nouns) == 68
      assert length(all_data.verbs) == 40
      assert length(all_data.adverbs) == 27
      assert length(all_data.prepositions) == 26
    end
  end

  describe "random_word/1" do
    test "should return random adjective" do
      adjective = Dictionary.random_word(:adjectives)

      assert is_binary(adjective)
      assert adjective in Dictionary.adjectives()
    end

    test "should return random noun" do
      noun = Dictionary.random_word(:nouns)

      assert is_binary(noun)
      assert noun in Dictionary.nouns()
    end

    test "should return random verb" do
      verb = Dictionary.random_word(:verbs)

      assert is_binary(verb)
      assert verb in Dictionary.verbs()
    end

    test "should return random adverb" do
      adverb = Dictionary.random_word(:adverbs)

      assert is_binary(adverb)
      assert adverb in Dictionary.adverbs()
    end

    test "should return random preposition" do
      preposition = Dictionary.random_word(:prepositions)

      assert is_binary(preposition)
      assert preposition in Dictionary.prepositions()
    end

    test "should return different words on multiple calls" do
      # Test randomness by calling multiple times
      words =
        1..20
        |> Enum.map(fn _ -> Dictionary.random_word(:adjectives) end)
        |> MapSet.new()

      # Should have some variety (allowing for some duplicates due to randomness)
      assert MapSet.size(words) > 1
    end
  end

  describe "word content validation" do
    test "should contain expected sample words from TypeScript version" do
      # Validate key words from original TypeScript implementation
      assert "cute" in Dictionary.adjectives()
      assert "dapper" in Dictionary.adjectives()
      assert "large" in Dictionary.adjectives()

      assert "rabbit" in Dictionary.nouns()
      assert "badger" in Dictionary.nouns()
      assert "fox" in Dictionary.nouns()

      assert "sing" in Dictionary.verbs()
      assert "play" in Dictionary.verbs()
      assert "knit" in Dictionary.verbs()

      assert "jovially" in Dictionary.adverbs()
      assert "merrily" in Dictionary.adverbs()
      assert "cordially" in Dictionary.adverbs()

      assert "in" in Dictionary.prepositions()
      assert "on" in Dictionary.prepositions()
      assert "at" in Dictionary.prepositions()
    end

    test "should not contain empty strings or nil values" do
      all_words =
        Dictionary.adjectives() ++
          Dictionary.nouns() ++
          Dictionary.verbs() ++
          Dictionary.adverbs() ++
          Dictionary.prepositions()

      for word <- all_words do
        assert is_binary(word)
        assert String.length(word) > 0
        refute is_nil(word)
      end
    end

    test "should contain only lowercase words" do
      all_words =
        Dictionary.adjectives() ++
          Dictionary.nouns() ++
          Dictionary.verbs() ++
          Dictionary.adverbs() ++
          Dictionary.prepositions()

      for word <- all_words do
        # Allow hyphens for compound words like "guinea-pig"
        assert String.match?(word, ~r/^[a-z-]+$/)
      end
    end
  end
end
