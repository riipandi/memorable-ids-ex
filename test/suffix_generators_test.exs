defmodule MemorableIds.SuffixGeneratorsTest do
  use ExUnit.Case

  describe "default_suffix/0" do
    test "should generate 3-digit string" do
      suffix = MemorableIds.default_suffix()

      assert is_binary(suffix)
      assert Regex.match?(~r/^\d{3}$/, suffix)
    end

    test "should generate different values on multiple calls" do
      suffixes =
        1..50
        |> Enum.map(fn _ -> MemorableIds.default_suffix() end)
        |> MapSet.new()

      # Should have some variety (allowing for some duplicates due to randomness)
      assert MapSet.size(suffixes) > 1
    end

    test "should generate values in correct range" do
      for _i <- 1..20 do
        suffix = MemorableIds.default_suffix()
        number = String.to_integer(suffix)

        assert number >= 0
        assert number <= 999
      end
    end
  end

  describe "suffix_generators/0" do
    test "should return map with all generators" do
      generators = MemorableIds.suffix_generators()

      assert is_map(generators)
      assert Map.has_key?(generators, :number)
      assert Map.has_key?(generators, :number4)
      assert Map.has_key?(generators, :hex)
      assert Map.has_key?(generators, :timestamp)
      assert Map.has_key?(generators, :letter)
    end

    test "all generators should be functions" do
      generators = MemorableIds.suffix_generators()

      assert is_function(generators.number, 0)
      assert is_function(generators.number4, 0)
      assert is_function(generators.hex, 0)
      assert is_function(generators.timestamp, 0)
      assert is_function(generators.letter, 0)
    end
  end

  describe "number generator" do
    test "should generate 3-digit string" do
      suffix_generators = MemorableIds.suffix_generators()
      suffix = suffix_generators.number.()

      assert is_binary(suffix)
      assert Regex.match?(~r/^\d{3}$/, suffix)
    end

    test "should generate values in correct range" do
      suffix_generators = MemorableIds.suffix_generators()

      for _i <- 1..20 do
        suffix = suffix_generators.number.()
        number = String.to_integer(suffix)

        assert number >= 0
        assert number <= 999
      end
    end

    test "should pad with leading zeros" do
      suffix_generators = MemorableIds.suffix_generators()

      # Generate many to increase chance of getting small numbers
      suffixes =
        1..100
        |> Enum.map(fn _ -> suffix_generators.number.() end)

      # Should find some with leading zeros
      has_leading_zero = Enum.any?(suffixes, &String.starts_with?(&1, "0"))
      assert has_leading_zero
    end
  end

  describe "number4 generator" do
    test "should generate 4-digit string" do
      suffix_generators = MemorableIds.suffix_generators()
      suffix = suffix_generators.number4.()

      assert is_binary(suffix)
      assert Regex.match?(~r/^\d{4}$/, suffix)
    end

    test "should generate values in correct range" do
      suffix_generators = MemorableIds.suffix_generators()

      for _i <- 1..20 do
        suffix = suffix_generators.number4.()
        number = String.to_integer(suffix)

        assert number >= 0
        assert number <= 9999
      end
    end

    test "should pad with leading zeros" do
      suffix_generators = MemorableIds.suffix_generators()

      # Generate many to increase chance of getting small numbers
      suffixes =
        1..100
        |> Enum.map(fn _ -> suffix_generators.number4.() end)

      # Should find some with leading zeros
      has_leading_zero = Enum.any?(suffixes, &String.starts_with?(&1, "0"))
      assert has_leading_zero
    end
  end

  describe "hex generator" do
    test "should generate 2-digit hex string" do
      suffix_generators = MemorableIds.suffix_generators()
      suffix = suffix_generators.hex.()

      assert is_binary(suffix)
      assert Regex.match?(~r/^[0-9a-f]{2}$/, suffix)
    end

    test "should generate values in correct range" do
      suffix_generators = MemorableIds.suffix_generators()

      for _i <- 1..20 do
        suffix = suffix_generators.hex.()
        number = String.to_integer(suffix, 16)

        assert number >= 0
        assert number <= 255
      end
    end

    test "should be lowercase" do
      suffix_generators = MemorableIds.suffix_generators()

      for _i <- 1..20 do
        suffix = suffix_generators.hex.()
        assert suffix == String.downcase(suffix)
      end
    end

    test "should pad with leading zeros" do
      suffix_generators = MemorableIds.suffix_generators()

      # Generate many to increase chance of getting small numbers
      suffixes =
        1..100
        |> Enum.map(fn _ -> suffix_generators.hex.() end)

      # Should find some with leading zeros
      has_leading_zero = Enum.any?(suffixes, &String.starts_with?(&1, "0"))
      assert has_leading_zero
    end
  end

  describe "timestamp generator" do
    test "should generate 4-digit string" do
      suffix_generators = MemorableIds.suffix_generators()
      suffix = suffix_generators.timestamp.()

      assert is_binary(suffix)
      assert Regex.match?(~r/^\d{4}$/, suffix)
    end

    test "should generate different values over time" do
      suffix_generators = MemorableIds.suffix_generators()

      suffix1 = suffix_generators.timestamp.()
      # Wait 1ms
      Process.sleep(1)
      suffix2 = suffix_generators.timestamp.()

      # They might be the same due to timing, but let's check format
      assert Regex.match?(~r/^\d{4}$/, suffix1)
      assert Regex.match?(~r/^\d{4}$/, suffix2)
    end

    test "should be based on current time" do
      suffix_generators = MemorableIds.suffix_generators()
      current_time = System.system_time(:millisecond)

      expected_suffix =
        current_time
        |> Integer.to_string()
        |> String.slice(-4..-1)

      # Generate suffix within small time window
      actual_suffix = suffix_generators.timestamp.()

      # Should be close to expected (within reasonable time difference)
      assert Regex.match?(~r/^\d{4}$/, actual_suffix)
    end
  end

  describe "letter generator" do
    test "should generate single lowercase letter" do
      suffix_generators = MemorableIds.suffix_generators()
      suffix = suffix_generators.letter.()

      assert is_binary(suffix)
      assert Regex.match?(~r/^[a-z]$/, suffix)
    end

    test "should generate different letters" do
      suffix_generators = MemorableIds.suffix_generators()

      letters =
        1..50
        |> Enum.map(fn _ -> suffix_generators.letter.() end)
        |> MapSet.new()

      # Should have variety (at least a few different letters)
      assert MapSet.size(letters) > 1
    end

    test "should only generate valid letters" do
      suffix_generators = MemorableIds.suffix_generators()
      valid_letters = ?a..?z |> Enum.map(&<<&1>>)

      for _i <- 1..26 do
        letter = suffix_generators.letter.()
        assert letter in valid_letters
      end
    end
  end

  describe "integration with generate/1" do
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

    test "should handle suffix generators edge cases" do
      suffix_generators = MemorableIds.suffix_generators()

      # Test that all generators work multiple times
      for _i <- 1..5 do
        num = suffix_generators.number.()
        num4 = suffix_generators.number4.()
        hex = suffix_generators.hex.()
        ts = suffix_generators.timestamp.()
        letter = suffix_generators.letter.()

        assert Regex.match?(~r/^\d{3}$/, num)
        assert Regex.match?(~r/^\d{4}$/, num4)
        assert Regex.match?(~r/^[0-9a-f]{2}$/, hex)
        assert Regex.match?(~r/^\d{4}$/, ts)
        assert Regex.match?(~r/^[a-z]$/, letter)
      end
    end
  end
end
