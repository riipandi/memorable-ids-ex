defmodule MemorableIds.ParseTest do
  use ExUnit.Case

  describe "parse/2 basic functionality" do
    test "should parse ID without suffix" do
      result = MemorableIds.parse("cute-rabbit")

      assert result == %{
               components: ["cute", "rabbit"],
               suffix: nil
             }
    end

    test "should parse ID with numeric suffix" do
      result = MemorableIds.parse("cute-rabbit-042")

      assert result == %{
               components: ["cute", "rabbit"],
               suffix: "042"
             }
    end

    test "should parse ID with non-numeric suffix as component" do
      result = MemorableIds.parse("cute-rabbit-swim")

      assert result == %{
               components: ["cute", "rabbit", "swim"],
               suffix: nil
             }
    end

    test "should handle single component" do
      result = MemorableIds.parse("cute")

      assert result == %{
               components: ["cute"],
               suffix: nil
             }
    end

    test "should handle single component with suffix" do
      result = MemorableIds.parse("cute-123")

      assert result == %{
               components: ["cute"],
               suffix: "123"
             }
    end
  end

  describe "parse/2 with custom separators" do
    test "should handle custom separator" do
      result = MemorableIds.parse("cute_rabbit_123", "_")

      assert result == %{
               components: ["cute", "rabbit"],
               suffix: "123"
             }
    end

    test "should handle parsing with different separators" do
      separators = ["_", ".", "|", ":"]

      for sep <- separators do
        result = MemorableIds.parse("word1#{sep}word2#{sep}123", sep)

        assert result == %{
                 components: ["word1", "word2"],
                 suffix: "123"
               }
      end
    end

    test "should use default separator when not specified" do
      result1 = MemorableIds.parse("cute-rabbit-123")
      result2 = MemorableIds.parse("cute-rabbit-123", "-")

      assert result1 == result2
    end
  end

  describe "parse/2 edge cases" do
    test "should handle ID with only numeric part" do
      result = MemorableIds.parse("123")

      assert result == %{
               components: [],
               suffix: "123"
             }
    end

    test "should handle mixed numeric patterns" do
      result = MemorableIds.parse("cute-123abc-456")

      assert result == %{
               components: ["cute", "123abc"],
               suffix: "456"
             }
    end

    test "should parse empty string gracefully" do
      result = MemorableIds.parse("")

      assert result == %{
               components: [""],
               suffix: nil
             }
    end

    test "should handle parsing IDs with no separators" do
      result = MemorableIds.parse("singleword")

      assert result == %{
               components: ["singleword"],
               suffix: nil
             }
    end

    test "should handle parsing numeric-only IDs" do
      result = MemorableIds.parse("123-456-789")

      assert result == %{
               components: ["123", "456"],
               suffix: "789"
             }
    end
  end

  describe "parse/2 suffix detection" do
    test "should detect various numeric suffix formats" do
      test_cases = [
        {"word-123", ["word"], "123"},
        {"word-0", ["word"], "0"},
        {"word-999", ["word"], "999"},
        {"word-0000", ["word"], "0000"},
        {"word1-word2-42", ["word1", "word2"], "42"}
      ]

      for {input, expected_components, expected_suffix} <- test_cases do
        result = MemorableIds.parse(input)
        assert result.components == expected_components
        assert result.suffix == expected_suffix
      end
    end

    test "should not detect non-numeric suffixes" do
      test_cases = [
        {"word-abc", ["word", "abc"], nil},
        {"word-123abc", ["word", "123abc"], nil},
        {"word-abc123", ["word", "abc123"], nil},
        {"word1-word2-word3", ["word1", "word2", "word3"], nil}
      ]

      for {input, expected_components, expected_suffix} <- test_cases do
        result = MemorableIds.parse(input)
        assert result.components == expected_components
        assert result.suffix == expected_suffix
      end
    end

    test "should handle multiple numeric parts correctly" do
      result = MemorableIds.parse("123-456-789")

      # Only the last numeric part should be treated as suffix
      assert result == %{
               components: ["123", "456"],
               suffix: "789"
             }
    end

    test "should handle leading zeros in suffix" do
      result = MemorableIds.parse("word-007")

      assert result == %{
               components: ["word"],
               suffix: "007"
             }
    end
  end

  describe "parse/2 integration with generate/1" do
    test "should correctly parse generated IDs without suffix" do
      id = MemorableIds.generate(%{components: 3})
      parsed = MemorableIds.parse(id)

      assert length(parsed.components) == 3
      assert parsed.suffix == nil
    end

    test "should correctly parse generated IDs with suffix" do
      suffix_generators = MemorableIds.suffix_generators()

      id =
        MemorableIds.generate(%{
          components: 2,
          suffix: suffix_generators.number
        })

      parsed = MemorableIds.parse(id)

      assert length(parsed.components) == 2
      assert parsed.suffix != nil
      assert Regex.match?(~r/^\d{3}$/, parsed.suffix)
    end

    test "should handle round trip with all component counts" do
      for components <- 1..5 do
        id = MemorableIds.generate(%{components: components})
        parsed = MemorableIds.parse(id)
        assert length(parsed.components) == components
        assert parsed.suffix == nil
      end
    end

    test "should handle round trip with custom separators" do
      separators = ["_", ".", "|"]

      for sep <- separators do
        id = MemorableIds.generate(%{components: 2, separator: sep})
        parsed = MemorableIds.parse(id, sep)

        assert length(parsed.components) == 2
        assert parsed.suffix == nil
      end
    end

    test "should handle round trip with all suffix generators" do
      suffix_generators = MemorableIds.suffix_generators()

      generators = [
        suffix_generators.number,
        suffix_generators.number4,
        suffix_generators.hex,
        suffix_generators.timestamp,
        suffix_generators.letter
      ]

      for generator <- generators do
        id =
          MemorableIds.generate(%{
            components: 2,
            suffix: generator
          })

        parsed = MemorableIds.parse(id)

        assert length(parsed.components) == 2
        assert parsed.suffix != nil
        assert is_binary(parsed.suffix)
      end
    end
  end

  describe "parse/2 error handling" do
    test "should handle malformed input gracefully" do
      # These should not crash, just return reasonable results
      test_cases = [
        {"", %{components: [""], suffix: nil}},
        {"-", %{components: ["", ""], suffix: nil}},
        {"--", %{components: ["", "", ""], suffix: nil}},
        {"-123", %{components: [""], suffix: "123"}},
        {"word-", %{components: ["word", ""], suffix: nil}}
      ]

      for {input, expected} <- test_cases do
        result = MemorableIds.parse(input)
        assert result == expected
      end
    end

    test "should handle very long inputs" do
      long_word = String.duplicate("a", 1000)
      result = MemorableIds.parse(long_word)

      assert result == %{
               components: [long_word],
               suffix: nil
             }
    end

    test "should handle inputs with many separators" do
      many_parts = Enum.join(1..20, "-")
      result = MemorableIds.parse(many_parts)

      # Last part should be suffix since it's numeric
      assert result.suffix == "20"
      assert length(result.components) == 19
    end
  end
end
