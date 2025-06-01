# MemorableIds

A flexible Elixir library for generating human-readable, memorable identifiers.
Uses combinations of adjectives, nouns, verbs, adverbs, and prepositions with optional numeric/custom suffixes.

## Features

- 🎯 **Human-readable** - Generate IDs like `cute-rabbit`, `quick-owl-dance-quietly`, etc
- 🔧 **Flexible** - 1-5 word components with customizable separators
- 📊 **Predictable** - Built-in collision analysis and capacity planning
- 🎲 **Extensible** - Custom suffix generators and vocabulary
- 📝 **Elixir** - Full type specs and documentation
- ⚡ **Fast** - High-performance ID generation
- 🪶 **Lightweight** - Small vocabulary, zero dependencies

## Installation

Add `memorable_ids` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:memorable_ids, "~> 0.1.0"}
  ]
end
```

## Quick Start

```elixir
# Basic usage - 2 components
MemorableIds.generate() # "cute-rabbit"

# More components for uniqueness
MemorableIds.generate(%{components: 3}) # "large-fox-swim"

# Add numeric suffix for extra capacity
suffix_generators = MemorableIds.suffix_generators()
MemorableIds.generate(%{
  components: 2, 
  suffix: suffix_generators.number
}) # "quick-mouse-042"

# Custom separator
MemorableIds.generate(%{
  components: 2, 
  separator: "_"
}) # "warm_duck"
```

## API Reference

### `generate(options \\ %{})`

Generate a memorable ID with customizable options.

**Parameters:**
- `options.components` (integer, 1-5): Number of word components (default: 2)
- `options.suffix` (function): Suffix generator function (default: nil)
- `options.separator` (string): Separator between parts (default: "-")

**Returns:** `string` - Generated memorable ID

**Examples:**

```elixir
# Different component counts
MemorableIds.generate(%{components: 1}) # "bright"
MemorableIds.generate(%{components: 2}) # "cute-rabbit" 
MemorableIds.generate(%{components: 3}) # "large-fox-swim"
MemorableIds.generate(%{components: 4}) # "happy-owl-dance-quietly"
MemorableIds.generate(%{components: 5}) # "clever-fox-run-quickly-through"

# With suffixes
suffix_generators = MemorableIds.suffix_generators()
MemorableIds.generate(%{
  components: 2, 
  suffix: suffix_generators.number
}) # "safe-rabbit-042"

MemorableIds.generate(%{
  components: 2, 
  suffix: suffix_generators.hex
}) # "bright-owl-a7"

# Custom separators
MemorableIds.generate(%{separator: "_"}) # "warm_duck"
MemorableIds.generate(%{separator: "."}) # "cute.rabbit"
```

### `parse(id, separator \\ "-")`

Parse a memorable ID back to its components.

**Parameters:**
- `id` (string): The memorable ID to parse
- `separator` (string): Separator used (default: "-")

**Returns:** `map` - Map with `components` list and `suffix` string

**Examples:**

```elixir
MemorableIds.parse("cute-rabbit-042")
# %{components: ["cute", "rabbit"], suffix: "042"}

MemorableIds.parse("large-fox-swim")
# %{components: ["large", "fox", "swim"], suffix: nil}

MemorableIds.parse("warm_duck_123", "_")
# %{components: ["warm", "duck"], suffix: "123"}
```

### Suffix Generators

Pre-built suffix generators for common use cases:

```elixir
suffix_generators = MemorableIds.suffix_generators()

# 3-digit number (000-999) - adds 1,000x multiplier
suffix_generators.number.() # "042"

# 4-digit number (0000-9999) - adds 10,000x multiplier  
suffix_generators.number4.() # "1337"

# 2-digit hex (00-ff) - adds 256x multiplier
suffix_generators.hex.() # "a7"

# Timestamp (last 4 digits) - time-based
suffix_generators.timestamp.() # "8429"

# Single letter (a-z) - adds 26x multiplier
suffix_generators.letter.() # "k"
```

### Analysis Functions

Plan capacity and understand collision probabilities:

```elixir
# Calculate total possible combinations
MemorableIds.calculate_combinations(2) # 5,304 (2 components)
MemorableIds.calculate_combinations(2, 1000) # 5,304,000 (2 components + 3-digit suffix)
MemorableIds.calculate_combinations(3) # 212,160 (3 components)

# Calculate collision probability (Birthday Paradox)
MemorableIds.calculate_collision_probability(5304, 100) # 0.0093 (0.93% chance)

# Get comprehensive analysis
MemorableIds.get_collision_analysis(2)
# %{
#   total_combinations: 5304,
#   scenarios: [
#     %{ids: 50, probability: 0.0023, percentage: "0.23%"},
#     %{ids: 100, probability: 0.0093, percentage: "0.93%"},
#     %{ids: 200, probability: 0.037, percentage: "3.7%"},
#     %{ids: 500, probability: 0.218, percentage: "21.8%"}
#   ]
# }
```

## Capacity & Collision Analysis

### Total Combinations by Component Count

| Components | Total IDs   | Example                          |
|------------|-------------|----------------------------------|
| 1          | 78          | `bright`                         |
| 2          | 5,304       | `cute-rabbit`                    |
| 3          | 212,160     | `large-fox-swim`                 |
| 4          | 5,728,320   | `happy-owl-dance-quietly`        |
| 5          | 148,936,320 | `clever-fox-run-quickly-through` |

### Suffix Multipliers

| Suffix Type    | Multiplier | Example            |
|----------------|------------|--------------------|
| 3-digit number | ×1,000     | `cute-rabbit-042`  |
| 4-digit number | ×10,000    | `cute-rabbit-1337` |
| 2-digit hex    | ×256       | `cute-rabbit-a7`   |
| Single letter  | ×26        | `cute-rabbit-k`    |

### Collision Probability Examples

**For 2 components (5,304 total combinations):**
- 50 IDs: 0.23% collision chance
- 100 IDs: 0.93% collision chance  
- 200 IDs: 3.7% collision chance
- 500 IDs: 21.8% collision chance

**For 3 components (212,160 total combinations):**
- 1,000 IDs: 0.002% collision chance
- 5,000 IDs: 0.059% collision chance
- 10,000 IDs: 0.235% collision chance
- 20,000 IDs: 0.94% collision chance

**For 2 components + 3-digit suffix (5,304,000 total combinations):**
- 10,000 IDs: 0.0009% collision chance
- 50,000 IDs: 0.023% collision chance
- 100,000 IDs: 0.094% collision chance
- 500,000 IDs: 2.35% collision chance

## Configuration Recommendations

Choose the right configuration based on your expected ID volume:

| Use Case                  | Recommendation          | Capacity | Example               |
|---------------------------|-------------------------|----------|-----------------------|
| Small apps (<1K IDs)      | 2 components            | 5,304    | `cute-rabbit`         |
| Medium apps (1K-50K IDs)  | 3 components            | 212,160  | `large-fox-swim`      |
| Large apps (50K-500K IDs) | 2-3 components + suffix | 5M+      | `cute-rabbit-042`     |
| Enterprise (500K+ IDs)    | 4+ components + suffix  | 50M+     | `happy-owl-dance-042` |

## Advanced Usage

### Custom Suffix Generators

Create your own suffix logic:

```elixir
# Custom timestamp suffix
timestamp_suffix = fn ->
  DateTime.utc_now()
  |> DateTime.to_unix(:millisecond)
  |> Integer.to_string()
  |> String.slice(-6..-1) # Last 6 digits
end

# Custom random string
random_string = fn ->
  :crypto.strong_rand_bytes(3)
  |> Base.encode32(case: :lower, padding: false)
  |> String.slice(0..2) # 3 random chars
end

# Use custom suffix
MemorableIds.generate(%{
  components: 2, 
  suffix: timestamp_suffix
}) # "cute-rabbit-123456"
```

### Dictionary Access

Access the underlying word collections:

```elixir
alias MemorableIds.Dictionary

IO.puts length(Dictionary.adjectives()) # 78
IO.puts length(Dictionary.nouns()) # 68
IO.puts length(Dictionary.verbs()) # 40
IO.puts length(Dictionary.adverbs()) # 27
IO.puts length(Dictionary.prepositions()) # 26

# Access individual words
IO.puts hd(Dictionary.adjectives()) # "cute"
IO.puts hd(Dictionary.nouns()) # "rabbit"

# Get statistics
stats = Dictionary.stats()
IO.inspect stats
# %{adjectives: 78, nouns: 68, verbs: 40, adverbs: 27, prepositions: 26}
```

### Error Handling

```elixir
try do
  MemorableIds.generate(%{components: 6}) # Invalid: max is 5
rescue
  ArgumentError -> IO.puts "Components must be between 1 and 5"
end
```

## Performance Considerations

### Generation Speed
- **High-performance** ID generation suitable for production use
- No significant performance difference between component counts
- Suffix generation adds minimal overhead

### Randomness Quality
- Uses Erlang's `:rand` module - suitable for non-cryptographic purposes
- For cryptographic security, replace with `:crypto.strong_rand_bytes/1`
- Distribution is uniform across all vocabulary combinations

## Security Notes

⚠️ **Important Security Information:**

- IDs are **NOT cryptographically secure**
- Predictable if random seed is known
- **Suitable for**: user-friendly identifiers, temporary IDs, non-sensitive references
- **NOT suitable for**: session tokens, passwords, security-critical identifiers

## Development

### Running Tests

```bash
# Run all tests
mix test

# Run with coverage
mix test --cover

# Run specific test file
mix test test/memorable_ids_test.exs

# Run doctests only
mix test --only doctest
```

### Building Documentation

```bash
# Generate documentation
mix docs

# View documentation
open doc/index.html
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### Development Setup

```bash
# Clone repository
git clone <repository-url>
cd memorable_ids

# Install dependencies
mix deps.get

# Run tests
mix test

# Check formatting
mix format --check-formatted

# Run static analysis
mix credo
```

### Adding Custom Vocabulary

1. Extend existing lists in `lib/dictionary.ex`
2. Ensure words are URL-safe and human-readable
3. Avoid duplicates to maintain combination count accuracy
4. Update tests and documentation
5. Run `mix test` to verify changes

## License

This project is open-sourced software licensed under the [MIT license](https://choosealicense.com/licenses/mit/).

Copyrights in this project are retained by their contributors.
See the [license file](./LICENSE) for more information.

---

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/memorable_ids>.
