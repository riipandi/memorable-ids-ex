defmodule MemorableIdsTest do
  use ExUnit.Case
  doctest MemorableIds

  describe "basic functionality" do
    test "should generate memorable IDs" do
      id = MemorableIds.generate()
      assert is_binary(id)
      assert String.contains?(id, "-")
    end

    test "should parse memorable IDs" do
      id = "cute-rabbit-123"
      result = MemorableIds.parse(id)

      assert result.components == ["cute", "rabbit"]
      assert result.suffix == "123"
    end

    test "should calculate combinations" do
      combinations = MemorableIds.calculate_combinations(2)
      # 78 * 68
      assert combinations == 5304
    end

    test "should calculate collision probability" do
      probability = MemorableIds.calculate_collision_probability(5304, 100)
      assert is_float(probability)
      assert probability >= 0.0
      assert probability <= 1.0
    end

    test "should provide collision analysis" do
      analysis = MemorableIds.get_collision_analysis(2)

      assert is_map(analysis)
      assert Map.has_key?(analysis, :total_combinations)
      assert Map.has_key?(analysis, :scenarios)
      assert analysis.total_combinations == 5304
    end
  end

  describe "generate/1" do
    test "should handle suffix that is nil" do
      nil_suffix = fn -> nil end

      id =
        MemorableIds.generate(%{
          components: 2,
          suffix: nil_suffix
        })

      parts = String.split(id, "-")

      # Should not add suffix when nil is returned
      assert length(parts) == 2
    end

    test "should handle suffix that returns nil" do
      id = MemorableIds.generate(%{suffix: nil})
      parts = String.split(id, "-")
      # No suffix added
      assert length(parts) == 2
    end
  end

  describe "integration tests" do
    test "should generate and parse ID correctly" do
      id = MemorableIds.generate(%{components: 3})
      parsed = MemorableIds.parse(id)

      assert length(parsed.components) == 3
      assert parsed.suffix == nil
    end

    test "should generate and parse ID with suffix correctly" do
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

    test "should work with all suffix generators" do
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

        parts = String.split(id, "-")
        # 2 components + 1 suffix
        assert length(parts) == 3
      end
    end

    test "should handle round trip with all component counts" do
      for components <- 1..5 do
        id = MemorableIds.generate(%{components: components})
        parsed = MemorableIds.parse(id)
        assert length(parsed.components) == components
        assert parsed.suffix == nil
      end
    end
  end

  describe "error handling" do
    test "should raise error for invalid component count" do
      assert_raise ArgumentError, "Components must be between 1 and 5", fn ->
        MemorableIds.generate(%{components: 0})
      end

      assert_raise ArgumentError, "Components must be between 1 and 5", fn ->
        MemorableIds.generate(%{components: 6})
      end
    end

    test "should handle edge cases gracefully" do
      # Empty options
      id = MemorableIds.generate(%{})
      assert is_binary(id)

      # Empty string parsing
      result = MemorableIds.parse("")
      assert is_map(result)

      # Nil suffix
      id = MemorableIds.generate(%{suffix: nil})
      assert is_binary(id)
    end
  end

  describe "performance and consistency" do
    test "should generate unique IDs consistently" do
      ids =
        1..100
        |> Enum.map(fn _ -> MemorableIds.generate() end)
        |> MapSet.new()

      # Should have high uniqueness
      assert MapSet.size(ids) > 90
    end

    test "should have consistent calculations" do
      # Test that calculations are deterministic
      combinations1 = MemorableIds.calculate_combinations(2, 1000)
      combinations2 = MemorableIds.calculate_combinations(2, 1000)
      assert combinations1 == combinations2

      probability1 = MemorableIds.calculate_collision_probability(5304, 100)
      probability2 = MemorableIds.calculate_collision_probability(5304, 100)
      assert probability1 == probability2
    end
  end

  describe "Dictionary module tests" do
    test "should have expected word counts" do
      # Test actual word counts match expected values
      assert length(MemorableIds.Dictionary.adjectives()) == 78
      assert length(MemorableIds.Dictionary.nouns()) == 68
      assert length(MemorableIds.Dictionary.verbs()) == 40
      assert length(MemorableIds.Dictionary.adverbs()) == 27
      assert length(MemorableIds.Dictionary.prepositions()) == 26
    end
  end
end
