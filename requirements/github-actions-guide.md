# GitHub Actions Guide

This fork is optimized for GitHub Actions with automatic caching and parallel test execution.

## Quick Start

### Single Test Suite

```yaml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        ci_node_total: [8]
        ci_node_index: [0, 1, 2, 3, 4, 5, 6, 7]

    steps:
      - uses: actions/checkout@v4

      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.2'
          bundler-cache: true

      - name: Run tests
        env:
          CI_NODE_TOTAL: ${{ matrix.ci_node_total }}
          CI_NODE_INDEX: ${{ matrix.ci_node_index }}
        run: bundle exec rake knapsack:rspec
```

**How it works:**
1. First run: Tests distributed alphabetically (no cache yet)
2. Cache automatically created in `./tmp/.knapsack/runtime.json`
3. Second run onwards: Tests optimally distributed using cached timings
4. No manual steps needed!

## Multiple Test Suites (Unit + Feature Tests)

### Problem Statement

You want to run `spec/unit` and `spec/features` as separate parallel jobs because:
- They have different characteristics (fast unit tests vs. slow feature tests)
- You want different parallelization (e.g., 4 nodes for unit, 8 for features)
- You want them to run simultaneously, not sequentially

### Solution

Use `KNAPSACK_TEST_FILE_PATTERN` to select tests and `KNAPSACK_CACHE_DIR` to separate caches:

```yaml
name: Tests

on: [push, pull_request]

jobs:
  unit-tests:
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        ci_node_total: [4]
        ci_node_index: [0, 1, 2, 3]

    steps:
      - uses: actions/checkout@v4

      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.2'
          bundler-cache: true

      - name: Run unit tests
        env:
          CI_NODE_TOTAL: ${{ matrix.ci_node_total }}
          CI_NODE_INDEX: ${{ matrix.ci_node_index }}
          KNAPSACK_TEST_FILE_PATTERN: "spec/unit/**/*_spec.rb"
          KNAPSACK_CACHE_DIR: "./tmp/.knapsack-unit"
        run: bundle exec rake knapsack:rspec

  feature-tests:
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        ci_node_total: [8]
        ci_node_index: [0, 1, 2, 3, 4, 5, 6, 7]

    steps:
      - uses: actions/checkout@v4

      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.2'
          bundler-cache: true

      - name: Run feature tests
        env:
          CI_NODE_TOTAL: ${{ matrix.ci_node_total }}
          CI_NODE_INDEX: ${{ matrix.ci_node_index }}
          KNAPSACK_TEST_FILE_PATTERN: "spec/features/**/*_spec.rb"
          KNAPSACK_CACHE_DIR: "./tmp/.knapsack-features"
        run: bundle exec rake knapsack:rspec
```

### How It Works

1. **Separate caches**: Each test suite maintains its own cache
   - Unit tests → `./tmp/.knapsack-unit/runtime.json`
   - Feature tests → `./tmp/.knapsack-features/runtime.json`

2. **Independent optimization**: Each cache tracks only its own tests
   - Unit cache knows about `spec/unit/**/*_spec.rb` files
   - Feature cache knows about `spec/features/**/*_spec.rb` files

3. **Parallel execution**: Both jobs run simultaneously
   - Unit tests finish quickly (fewer, faster tests)
   - Feature tests run longer (more, slower tests)
   - Overall CI time = max(unit_time, feature_time), not sum!

4. **Different parallelization**: Each suite uses optimal node count
   - Unit tests: 4 nodes (sufficient for fast tests)
   - Feature tests: 8 nodes (needed for slower tests)

### Verification Test

Verified working with integration tests:

```bash
$ ruby tmp/verify_multiple_suites.rb

Testing multiple test suite support with integration tests...
======================================================================

1. Running 'unit' tests (fast_01 through fast_05)
   KNAPSACK_CACHE_DIR=./tmp/.knapsack-unit
   ✅ Unit cache created with 3 entries

2. Running 'feature' tests (slow_01 through slow_05)
   KNAPSACK_CACHE_DIR=./tmp/.knapsack-features
   ✅ Feature cache created with 3 entries

3. Verifying caches are completely separate:
   Unit cache: 3 entries
   Feature cache: 3 entries
   ✅ No overlap - caches are independent!

======================================================================
✅ SUCCESS: Multiple test suite support works correctly!
```

## Optional: Cache Persistence

If you want faster convergence, persist the cache across CI runs:

```yaml
- name: Cache Knapsack runtime data
  uses: actions/cache@v3
  with:
    path: |
      tmp/.knapsack-unit
      tmp/.knapsack-features
    key: knapsack-${{ github.ref }}-${{ github.sha }}
    restore-keys: |
      knapsack-${{ github.ref }}-
      knapsack-

- name: Run tests
  env:
    CI_NODE_TOTAL: ${{ matrix.ci_node_total }}
    CI_NODE_INDEX: ${{ matrix.ci_node_index }}
    KNAPSACK_TEST_FILE_PATTERN: "spec/unit/**/*_spec.rb"
    KNAPSACK_CACHE_DIR: "./tmp/.knapsack-unit"
  run: bundle exec rake knapsack:rspec
```

**Benefits:**
- Faster convergence to optimal distribution
- First run after branch creation uses cached timings from main

**Note:** This is optional. The cache naturally converges over a few runs even without persistence.

## Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `CI_NODE_TOTAL` | Total number of parallel nodes | `8` |
| `CI_NODE_INDEX` | Current node index (0-based) | `0` to `7` |
| `KNAPSACK_TEST_FILE_PATTERN` | Glob pattern for test files | `spec/unit/**/*_spec.rb` |
| `KNAPSACK_CACHE_DIR` | Cache directory path | `./tmp/.knapsack-unit` |
| `KNAPSACK_VERBOSE` | Show verbose output | `true` |

## Performance Expectations

With 50 test files, 8 parallel nodes:
- **Run 1 (no cache)**: 65.2% variance - some nodes finish 2x faster than others
- **Run 2+ (with cache)**: 0.7% variance - all nodes finish within seconds of each other

**Rule of thumb**: Aim for 5-10 test files per node for optimal balance.

## Troubleshooting

### Tests not balanced on first run

**Expected behavior.** First run has no cache, so tests are distributed alphabetically. Second run onwards will be optimally balanced.

### Tests still not balanced after multiple runs

Check if you have enough test files:
- With 10 files / 8 nodes (1.25 ratio): Poor balance possible
- With 50 files / 8 nodes (6.25 ratio): Excellent balance guaranteed

### Multiple test suites sharing same cache

Make sure you set different `KNAPSACK_CACHE_DIR` for each job:
```yaml
# ✅ Correct - separate caches
KNAPSACK_CACHE_DIR: "./tmp/.knapsack-unit"
KNAPSACK_CACHE_DIR: "./tmp/.knapsack-features"

# ❌ Wrong - shared cache
# (both jobs use default ./tmp/.knapsack/)
```

### Cache not persisting across CI runs

If you want persistence, add the `actions/cache` step. Otherwise, cache naturally rebuilds on each run (still works great, just starts fresh each time).
