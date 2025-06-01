ExUnit.start()

# Configure ExUnit for better test output
ExUnit.configure(exclude: [:skip], formatters: [ExUnit.CLIFormatter])

# Seed random number generator for consistent test results when needed
:rand.seed(:exsss, {1, 2, 3})
