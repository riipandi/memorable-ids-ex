defmodule MemorableIds.GenerateTest do
  use ExUnit.Case

  alias MemorableIds.Dictionary

  describe "generate/1 with default options" do
    test "should generate ID with default options (2 components)" do
      id = MemorableIds.generate()
      parts = String.split(id, "-")

      assert length(parts) == 2
      assert Enum.at(parts, 0) in Dictionary.adjectives()
      assert Enum.at(parts, 1) in Dictionary.nouns()
    end

    test "should generate different IDs on multiple calls" do
      ids =
        1..100
        |> Enum.map(fn _ -> MemorableIds.generate() end)
        |> MapSet.new()

      # Should have high uniqueness (allowing for some collisions)
      assert MapSet.size(ids) > 90
    end

    test "should handle empty options map" do
      id = MemorableIds.generate(%{})
      parts = String.split(id, "-")

      # default behavior
      assert length(parts) == 2
    end
  end

  describe "generate/1 with different component counts" do
    test "should generate ID with 1 component" do
      id = MemorableIds.generate(%{components: 1})
      parts = String.split(id, "-")

      assert length(parts) == 1
      assert Enum.at(parts, 0) in Dictionary.adjectives()
    end

    test "should generate ID with 3 components" do
      id = MemorableIds.generate(%{components: 3})
      parts = String.split(id, "-")

      assert length(parts) == 3
      assert Enum.at(parts, 0) in Dictionary.adjectives()
      assert Enum.at(parts, 1) in Dictionary.nouns()
      assert Enum.at(parts, 2) in Dictionary.verbs()
    end

    test "should generate ID with 4 components" do
      id = MemorableIds.generate(%{components: 4})
      parts = String.split(id, "-")

      assert length(parts) == 4
      assert Enum.at(parts, 0) in Dictionary.adjectives()
      assert Enum.at(parts, 1) in Dictionary.nouns()
      assert Enum.at(parts, 2) in Dictionary.verbs()
      assert Enum.at(parts, 3) in Dictionary.adverbs()
    end

    test "should generate ID with 5 components" do
      id = MemorableIds.generate(%{components: 5})
      parts = String.split(id, "-")

      assert length(parts) == 5
      assert Enum.at(parts, 0) in Dictionary.adjectives()
      assert Enum.at(parts, 1) in Dictionary.nouns()
      assert Enum.at(parts, 2) in Dictionary.verbs()
      assert Enum.at(parts, 3) in Dictionary.adverbs()
      assert Enum.at(parts, 4) in Dictionary.prepositions()
    end
  end

  describe "generate/1 with custom separators" do
    test "should use custom separator" do
      id = MemorableIds.generate(%{components: 2, separator: "_"})
      parts = String.split(id, "_")

      assert length(parts) == 2
      assert String.contains?(id, "_")
      assert Enum.at(parts, 0) in Dictionary.adjectives()
      assert Enum.at(parts, 1) in Dictionary.nouns()
    end

    test "should work with different separators" do
      separators = ["_", ".", "|", ":"]

      for sep <- separators do
        id = MemorableIds.generate(%{components: 2, separator: sep})
        parts = String.split(id, sep)

        assert length(parts) == 2
        assert String.contains?(id, sep)
      end
    end
  end

  describe "generate/1 with suffixes" do
    test "should add suffix when provided" do
      suffix_generators = MemorableIds.suffix_generators()

      id =
        MemorableIds.generate(%{
          components: 2,
          suffix: suffix_generators.number
        })

      parts = String.split(id, "-")

      assert length(parts) == 3
      assert Regex.match?(~r/^\d{3}$/, Enum.at(parts, 2))
    end

    test "should handle nil suffix gracefully" do
      null_suffix = fn -> nil end

      id =
        MemorableIds.generate(%{
          components: 2,
          suffix: null_suffix
        })

      parts = String.split(id, "-")

      assert length(parts) == 2
    end

    test "should handle suffix that is nil" do
      id =
        MemorableIds.generate(%{
          components: 2,
          suffix: nil
        })

      parts = String.split(id, "-")

      assert length(parts) == 2
    end

    test "should handle custom suffix returning empty string" do
      empty_suffix = fn -> "" end

      id =
        MemorableIds.generate(%{
          components: 2,
          suffix: empty_suffix
        })

      parts = String.split(id, "-")

      # empty string is still added
      assert length(parts) == 3
      assert Enum.at(parts, 2) == ""
    end

    test "should handle custom suffix returning whitespace" do
      whitespace_suffix = fn -> "   " end

      id =
        MemorableIds.generate(%{
          components: 2,
          suffix: whitespace_suffix
        })

      parts = String.split(id, "-")

      assert length(parts) == 3
      assert Enum.at(parts, 2) == "   "
    end
  end

  describe "generate/1 error handling" do
    test "should raise error for invalid component count" do
      assert_raise ArgumentError, "Components must be between 1 and 5", fn ->
        MemorableIds.generate(%{components: 0})
      end

      assert_raise ArgumentError, "Components must be between 1 and 5", fn ->
        MemorableIds.generate(%{components: 6})
      end

      assert_raise ArgumentError, "Components must be between 1 and 5", fn ->
        MemorableIds.generate(%{components: -1})
      end

      assert_raise ArgumentError, "Components must be between 1 and 5", fn ->
        MemorableIds.generate(%{components: 10})
      end
    end

    test "should handle invalid suffix function gracefully" do
      invalid_suffix = fn ->
        raise "Suffix generation failed"
      end

      # Should raise the error from the suffix function
      assert_raise RuntimeError, "Suffix generation failed", fn ->
        MemorableIds.generate(%{
          components: 2,
          suffix: invalid_suffix
        })
      end
    end
  end

  describe "generate/1 component validation" do
    test "should validate all component ranges work correctly" do
      # Test that each component position uses correct dictionary
      id1 = MemorableIds.generate(%{components: 1})
      parts1 = String.split(id1, "-")
      assert Enum.at(parts1, 0) in Dictionary.adjectives()

      id2 = MemorableIds.generate(%{components: 2})
      parts2 = String.split(id2, "-")
      assert Enum.at(parts2, 0) in Dictionary.adjectives()
      assert Enum.at(parts2, 1) in Dictionary.nouns()

      id3 = MemorableIds.generate(%{components: 3})
      parts3 = String.split(id3, "-")
      assert Enum.at(parts3, 0) in Dictionary.adjectives()
      assert Enum.at(parts3, 1) in Dictionary.nouns()
      assert Enum.at(parts3, 2) in Dictionary.verbs()

      id4 = MemorableIds.generate(%{components: 4})
      parts4 = String.split(id4, "-")
      assert Enum.at(parts4, 0) in Dictionary.adjectives()
      assert Enum.at(parts4, 1) in Dictionary.nouns()
      assert Enum.at(parts4, 2) in Dictionary.verbs()
      assert Enum.at(parts4, 3) in Dictionary.adverbs()

      id5 = MemorableIds.generate(%{components: 5})
      parts5 = String.split(id5, "-")
      assert Enum.at(parts5, 0) in Dictionary.adjectives()
      assert Enum.at(parts5, 1) in Dictionary.nouns()
      assert Enum.at(parts5, 2) in Dictionary.verbs()
      assert Enum.at(parts5, 3) in Dictionary.adverbs()
      assert Enum.at(parts5, 4) in Dictionary.prepositions()
    end

    test "should maintain consistency across multiple generations" do
      suffix_generators = MemorableIds.suffix_generators()

      options = %{
        components: 3,
        suffix: suffix_generators.hex,
        separator: "_"
      }

      for _i <- 1..10 do
        id = MemorableIds.generate(options)
        parts = String.split(id, "_")

        # 3 components + 1 suffix
        assert length(parts) == 4
        # hex suffix
        assert Regex.match?(~r/^[0-9a-f]{2}$/, List.last(parts))
      end
    end
  end
end
