defmodule MemorableIds do
  @moduledoc """
  Memorable ID Generator

  A flexible library for generating human-readable, memorable identifiers.
  Uses combinations of adjectives, nouns, verbs, adverbs, and prepositions
  with optional numeric/custom suffixes.
  """

  alias MemorableIds.Dictionary

  @doc """
  Generate a memorable ID

  ## Options

  * `:components` - Number of word components (1-5, default: 2)
  * `:suffix` - Suffix generator function (default: nil)
  * `:separator` - Separator between parts (default: "-")

  ## Examples

      iex> id = MemorableIds.generate()
      iex> String.contains?(id, "-")
      true

      iex> id = MemorableIds.generate(%{components: 3})
      iex> length(String.split(id, "-"))
      3

      iex> id = MemorableIds.generate(%{components: 2, suffix: &MemorableIds.default_suffix/0})
      iex> String.match?(id, ~r/.*-\\d{3}$/)
      true

      iex> id = MemorableIds.generate(%{components: 2, separator: "_"})
      iex> String.contains?(id, "_")
      true
  """
  def generate(options \\ %{}) do
    components = Map.get(options, :components, 2)
    suffix = Map.get(options, :suffix, nil)
    separator = Map.get(options, :separator, "-")

    if components < 1 or components > 5 do
      raise ArgumentError, "Components must be between 1 and 5"
    end

    component_generators = [
      # 0: adjective
      fn -> Dictionary.random_word(:adjectives) end,
      # 1: noun
      fn -> Dictionary.random_word(:nouns) end,
      # 2: verb
      fn -> Dictionary.random_word(:verbs) end,
      # 3: adverb
      fn -> Dictionary.random_word(:adverbs) end,
      # 4: preposition
      fn -> Dictionary.random_word(:prepositions) end
    ]

    # Generate requested number of components
    parts =
      0..(components - 1)
      |> Enum.map(fn i -> Enum.at(component_generators, i).() end)

    # Add suffix if provided
    final_parts =
      if suffix && is_function(suffix, 0) do
        case suffix.() do
          nil -> parts
          suffix_value -> parts ++ [suffix_value]
        end
      else
        parts
      end

    Enum.join(final_parts, separator)
  end

  @doc """
  Default suffix generator - random 3-digit number

  ## Examples

      iex> suffix = MemorableIds.default_suffix()
      iex> String.match?(suffix, ~r/^\\d{3}$/)
      true

      iex> suffix = MemorableIds.default_suffix()
      iex> String.length(suffix)
      3
  """
  def default_suffix do
    (:rand.uniform(1000) - 1)
    |> Integer.to_string()
    |> String.pad_leading(3, "0")
  end

  @doc """
  Parse a memorable ID back to its components

  ## Examples

      iex> MemorableIds.parse("cute-rabbit-042")
      %{components: ["cute", "rabbit"], suffix: "042"}

      iex> MemorableIds.parse("large-fox-swim")
      %{components: ["large", "fox", "swim"], suffix: nil}

      iex> MemorableIds.parse("cute_rabbit_123", "_")
      %{components: ["cute", "rabbit"], suffix: "123"}
  """
  def parse(id, separator \\ "-") do
    parts = String.split(id, separator)

    # Last part is likely suffix if it's numeric
    case List.last(parts) do
      nil ->
        %{components: [], suffix: nil}

      last_part ->
        if Regex.match?(~r/^\d+$/, last_part) do
          components = Enum.drop(parts, -1)
          %{components: components, suffix: last_part}
        else
          %{components: parts, suffix: nil}
        end
    end
  end

  @doc """
  Calculate total possible combinations for given configuration

  ## Examples

      iex> combinations = MemorableIds.calculate_combinations(2)
      iex> stats = MemorableIds.Dictionary.stats()
      iex> combinations == stats.adjectives * stats.nouns
      true

      iex> combinations = MemorableIds.calculate_combinations(2, 1000)
      iex> stats = MemorableIds.Dictionary.stats()
      iex> combinations == stats.adjectives * stats.nouns * 1000
      true

      iex> combinations = MemorableIds.calculate_combinations(3)
      iex> stats = MemorableIds.Dictionary.stats()
      iex> combinations == stats.adjectives * stats.nouns * stats.verbs
      true
  """
  def calculate_combinations(components \\ 2, suffix_range \\ 1) do
    stats = Dictionary.stats()

    component_sizes = [
      stats.adjectives,
      stats.nouns,
      stats.verbs,
      stats.adverbs,
      stats.prepositions
    ]

    total =
      0..(components - 1)
      |> Enum.reduce(1, fn i, acc ->
        acc * Enum.at(component_sizes, i)
      end)

    total * suffix_range
  end

  @doc """
  Calculate collision probability using Birthday Paradox

  ## Examples

      iex> total_combinations = MemorableIds.calculate_combinations(2)
      iex> prob = MemorableIds.calculate_collision_probability(total_combinations, 100)
      iex> is_float(prob) and prob >= 0.0 and prob <= 1.0
      true

      iex> total_combinations = MemorableIds.calculate_combinations(3)
      iex> prob = MemorableIds.calculate_collision_probability(total_combinations, 10000)
      iex> is_float(prob) and prob >= 0.0 and prob <= 1.0
      true
  """
  def calculate_collision_probability(total_combinations, generated_ids) do
    cond do
      generated_ids >= total_combinations ->
        1.0

      generated_ids <= 1 ->
        0.0

      true ->
        # Birthday paradox approximation: 1 - e^(-n²/2N)
        exponent = -(generated_ids * generated_ids) / (2 * total_combinations)
        1.0 - :math.exp(exponent)
    end
  end

  @doc """
  Get collision analysis for different ID generation scenarios

  ## Examples

      iex> analysis = MemorableIds.get_collision_analysis(2)
      iex> expected = MemorableIds.calculate_combinations(2)
      iex> analysis.total_combinations == expected
      true

      iex> analysis = MemorableIds.get_collision_analysis(2)
      iex> is_list(analysis.scenarios)
      true

      iex> analysis = MemorableIds.get_collision_analysis(2)
      iex> length(analysis.scenarios) >= 0
      true
  """
  def get_collision_analysis(components \\ 2, suffix_range \\ 1) do
    total = calculate_combinations(components, suffix_range)
    test_sizes = [50, 100, 200, 500, 1000, 2000, 5000, 10000, 20000, 50000]

    scenarios =
      test_sizes
      # Only show realistic scenarios
      |> Enum.filter(fn size -> size < total * 0.8 end)
      |> Enum.map(fn size ->
        probability = calculate_collision_probability(total, size)

        percentage =
          (probability * 100)
          |> Float.round(2)
          |> case do
            float when is_float(float) ->
              # Ensure we always have 2 decimal places
              :io_lib.format("~.2f", [float])
              |> List.to_string()
              |> Kernel.<>("%")

            _ ->
              "0.00%"
          end

        %{
          ids: size,
          probability: probability,
          percentage: percentage
        }
      end)

    %{
      total_combinations: total,
      scenarios: scenarios
    }
  end

  @doc """
  Collection of predefined suffix generators

  ## Examples

      iex> generators = MemorableIds.suffix_generators()
      iex> is_map(generators)
      true

      iex> generators = MemorableIds.suffix_generators()
      iex> is_function(generators.number, 0)
      true
  """
  def suffix_generators do
    %{
      # Random 3-digit number (000-999)
      number: &default_suffix/0,

      # Random 4-digit number (0000-9999)
      number4: fn ->
        (:rand.uniform(10000) - 1)
        |> Integer.to_string()
        |> String.pad_leading(4, "0")
      end,

      # Random 2-digit hex (00-ff)
      hex: fn ->
        (:rand.uniform(256) - 1)
        |> Integer.to_string(16)
        |> String.downcase()
        |> String.pad_leading(2, "0")
      end,

      # Last 4 digits of current timestamp
      timestamp: fn ->
        System.system_time(:millisecond)
        |> Integer.to_string()
        |> String.slice(-4..-1)
      end,

      # Random lowercase letter (a-z)
      letter: fn ->
        (?a + :rand.uniform(26) - 1)
        |> List.wrap()
        |> List.to_string()
      end
    }
  end
end
