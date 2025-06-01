defmodule MemorableIds.CollisionAnalysisTest do
  use ExUnit.Case

  alias MemorableIds.Dictionary

  describe "calculate_combinations/2" do
    test "should calculate combinations for 1 component" do
      combinations = MemorableIds.calculate_combinations(1)
      expected = Dictionary.stats().adjectives
      assert combinations == expected
    end

    test "should calculate combinations for 2 components" do
      combinations = MemorableIds.calculate_combinations(2)
      stats = Dictionary.stats()
      expected = stats.adjectives * stats.nouns
      assert combinations == expected
    end

    test "should calculate combinations for 3 components" do
      combinations = MemorableIds.calculate_combinations(3)
      stats = Dictionary.stats()
      expected = stats.adjectives * stats.nouns * stats.verbs
      assert combinations == expected
    end

    test "should calculate combinations for 4 components" do
      combinations = MemorableIds.calculate_combinations(4)
      stats = Dictionary.stats()
      expected = stats.adjectives * stats.nouns * stats.verbs * stats.adverbs
      assert combinations == expected
    end

    test "should calculate combinations for 5 components" do
      combinations = MemorableIds.calculate_combinations(5)
      stats = Dictionary.stats()
      expected = stats.adjectives * stats.nouns * stats.verbs * stats.adverbs * stats.prepositions
      assert combinations == expected
    end

    test "should apply suffix multiplier" do
      combinations = MemorableIds.calculate_combinations(2, 1000)
      stats = Dictionary.stats()
      expected = stats.adjectives * stats.nouns * 1000
      assert combinations == expected
    end

    test "should handle default parameters" do
      combinations = MemorableIds.calculate_combinations()
      stats = Dictionary.stats()
      expected = stats.adjectives * stats.nouns
      assert combinations == expected
    end

    test "should handle zero suffix range" do
      combinations = MemorableIds.calculate_combinations(2, 0)
      assert combinations == 0
    end

    test "should handle boundary values" do
      stats = Dictionary.stats()

      # Test with minimum values
      assert MemorableIds.calculate_combinations(1, 1) == stats.adjectives

      # Test with large suffix range
      large_combinations = MemorableIds.calculate_combinations(1, 999_999)
      expected = stats.adjectives * 999_999
      assert large_combinations == expected
    end

    test "should handle very large suffix ranges" do
      combinations = MemorableIds.calculate_combinations(1, 1_000_000)
      stats = Dictionary.stats()
      expected = stats.adjectives * 1_000_000
      assert combinations == expected
    end
  end

  describe "calculate_collision_probability/2" do
    test "should return 0.0 for 1 or fewer IDs" do
      assert MemorableIds.calculate_collision_probability(1000, 0) == 0.0
      assert MemorableIds.calculate_collision_probability(1000, 1) == 0.0
      assert MemorableIds.calculate_collision_probability(1000, -1) == 0.0
    end

    test "should return 1.0 when IDs >= total combinations" do
      assert MemorableIds.calculate_collision_probability(100, 100) == 1.0
      assert MemorableIds.calculate_collision_probability(100, 150) == 1.0
    end

    test "should return probability between 0 and 1 for normal cases" do
      total_combinations = MemorableIds.calculate_combinations(2)
      probability = MemorableIds.calculate_collision_probability(total_combinations, 100)

      assert probability >= 0.0
      assert probability <= 1.0
      assert probability > 0.0
    end

    test "should increase probability with more IDs" do
      total_combinations = MemorableIds.calculate_combinations(2)
      prob1 = MemorableIds.calculate_collision_probability(total_combinations, 50)
      prob2 = MemorableIds.calculate_collision_probability(total_combinations, 100)
      prob3 = MemorableIds.calculate_collision_probability(total_combinations, 200)

      assert prob1 < prob2
      assert prob2 < prob3
    end

    test "should handle edge case with very small total combinations" do
      probability = MemorableIds.calculate_collision_probability(2, 2)
      assert probability == 1.0
    end

    test "should handle extreme collision probability scenarios" do
      # Test with very large numbers
      prob1 = MemorableIds.calculate_collision_probability(1_000_000, 1000)
      assert prob1 >= 0.0 and prob1 <= 1.0

      # Test with equal numbers
      prob2 = MemorableIds.calculate_collision_probability(100, 100)
      assert prob2 == 1.0

      # Test with very small combinations
      prob3 = MemorableIds.calculate_collision_probability(1, 2)
      assert prob3 == 1.0
    end

    test "should handle mathematical edge cases" do
      # Test very small probability calculations
      prob = MemorableIds.calculate_collision_probability(1_000_000, 2)
      assert prob > 0.0 and prob < 0.001

      # Test approaching 50% probability (birthday paradox sweet spot)
      combinations = 365
      # Approximate 50% point
      ids = :math.sqrt(2 * combinations * :math.log(2)) |> trunc()
      prob50 = MemorableIds.calculate_collision_probability(combinations, ids)
      assert prob50 > 0.4 and prob50 < 0.6
    end

    test "should match expected values for known scenarios" do
      total_combinations = MemorableIds.calculate_combinations(2)

      # For 100 IDs, probability should be reasonable
      prob = MemorableIds.calculate_collision_probability(total_combinations, 100)
      # Just check it's a reasonable probability
      assert prob > 0.0 and prob < 1.0
    end
  end

  describe "get_collision_analysis/2" do
    test "should return analysis with total combinations" do
      analysis = MemorableIds.get_collision_analysis(2)

      assert is_map(analysis)
      assert Map.has_key?(analysis, :total_combinations)
      expected = MemorableIds.calculate_combinations(2)
      assert analysis.total_combinations == expected
    end

    test "should return scenarios list" do
      analysis = MemorableIds.get_collision_analysis(2)

      assert Map.has_key?(analysis, :scenarios)
      assert is_list(analysis.scenarios)
    end

    test "should have valid scenario structure" do
      analysis = MemorableIds.get_collision_analysis(2)

      if length(analysis.scenarios) > 0 do
        scenario = List.first(analysis.scenarios)

        assert is_map(scenario)
        assert Map.has_key?(scenario, :ids)
        assert Map.has_key?(scenario, :probability)
        assert Map.has_key?(scenario, :percentage)

        assert is_integer(scenario.ids)
        assert is_float(scenario.probability)
        assert is_binary(scenario.percentage)
        assert String.ends_with?(scenario.percentage, "%")
      end
    end

    test "should filter out unrealistic scenarios" do
      analysis = MemorableIds.get_collision_analysis(2)

      # All scenarios should be less than 80% of total combinations
      for scenario <- analysis.scenarios do
        assert scenario.ids < analysis.total_combinations * 0.8
      end
    end

    test "should handle suffix range" do
      analysis = MemorableIds.get_collision_analysis(2, 1000)
      expected = MemorableIds.calculate_combinations(2, 1000)
      assert analysis.total_combinations == expected
    end

    test "should handle all component counts" do
      for i <- 1..5 do
        analysis = MemorableIds.get_collision_analysis(i)
        assert analysis.total_combinations > 0
        assert is_list(analysis.scenarios)
      end
    end

    test "should handle very small combinations that filter all scenarios" do
      analysis = MemorableIds.get_collision_analysis(1, 1)

      # Should still return valid structure even if scenarios array might be empty or small
      assert is_integer(analysis.total_combinations)
      assert is_list(analysis.scenarios)
    end

    test "should have scenarios in ascending order by ID count" do
      analysis = MemorableIds.get_collision_analysis(3)

      if length(analysis.scenarios) > 1 do
        ids_list = Enum.map(analysis.scenarios, & &1.ids)
        sorted_ids = Enum.sort(ids_list)
        assert ids_list == sorted_ids
      end
    end

    test "should have increasing probabilities" do
      analysis = MemorableIds.get_collision_analysis(3)

      if length(analysis.scenarios) > 1 do
        probabilities = Enum.map(analysis.scenarios, & &1.probability)

        # Check that probabilities are generally increasing
        for {prob1, prob2} <- Enum.zip(probabilities, tl(probabilities)) do
          assert prob1 <= prob2
        end
      end
    end

    test "should format percentages correctly" do
      analysis = MemorableIds.get_collision_analysis(2)

      for scenario <- analysis.scenarios do
        # Should be formatted with % sign
        assert String.ends_with?(scenario.percentage, "%")

        # Percentage should match probability
        percentage_value =
          scenario.percentage
          |> String.trim_trailing("%")
          |> String.to_float()

        expected_percentage = scenario.probability * 100
        assert abs(percentage_value - expected_percentage) < 0.01
      end
    end

    test "should handle edge cases gracefully" do
      # Test with minimum components
      analysis1 = MemorableIds.get_collision_analysis(1)
      expected1 = MemorableIds.calculate_combinations(1)
      assert analysis1.total_combinations == expected1
      assert is_list(analysis1.scenarios)

      # Test with maximum components
      analysis5 = MemorableIds.get_collision_analysis(5)
      assert analysis5.total_combinations > 0
      assert is_list(analysis5.scenarios)

      # Test with large suffix range
      analysis_large = MemorableIds.get_collision_analysis(1, 10000)
      expected_large = MemorableIds.calculate_combinations(1, 10000)
      assert analysis_large.total_combinations == expected_large
      assert is_list(analysis_large.scenarios)
    end
  end

  describe "integration tests" do
    test "should have consistent calculations across functions" do
      components = 2
      suffix_range = 1000

      # Calculate combinations
      total_combinations = MemorableIds.calculate_combinations(components, suffix_range)

      # Get analysis
      analysis = MemorableIds.get_collision_analysis(components, suffix_range)

      # Should match
      assert analysis.total_combinations == total_combinations

      # Test probability calculation for each scenario
      for scenario <- analysis.scenarios do
        calculated_prob =
          MemorableIds.calculate_collision_probability(
            total_combinations,
            scenario.ids
          )

        # Should be very close (allowing for floating point precision)
        assert abs(calculated_prob - scenario.probability) < 0.0001
      end
    end

    test "should work with realistic ID generation scenarios" do
      # Test scenarios that might occur in real usage
      test_cases = [
        # 2 components, no suffix
        {2, 1, [100, 500, 1000]},
        # 2 components with 3-digit suffix
        {2, 1000, [1000, 5000, 10000]},
        # 3 components, no suffix
        {3, 1, [1000, 5000, 10000]}
      ]

      for {components, suffix_range, test_ids} <- test_cases do
        total_combinations = MemorableIds.calculate_combinations(components, suffix_range)

        for ids <- test_ids do
          # Only test realistic scenarios
          if ids < total_combinations * 0.8 do
            probability = MemorableIds.calculate_collision_probability(total_combinations, ids)

            assert probability >= 0.0
            assert probability <= 1.0
            assert is_float(probability)
          end
        end
      end
    end
  end
end
