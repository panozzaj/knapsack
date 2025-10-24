# Knapsack Fork Enhancement Plan

## Overview

This document outlines the enhancements to the Knapsack gem to make it production-ready with **zero-configuration automatic runtime tracking** and better test balancing.

**Design Philosophy: "Set it and forget it"**
- No manual report generation
- No git commits of runtime data
- Local development uses `./tmp/.knapsack/`
- CI uses artifacts/cache automatically
- Smart defaults that just work
- Helpful messaging on first run, quiet thereafter (unless verbose mode)

## Core Requirements

### 1. Better Handling of New/Removed Tests
**Current State:**
- New tests get assigned to nodes alphabetically (via LeftoverDistributor)
- No intelligence about likely execution time for new tests
- Removed tests are silently ignored in report

**Proposed Enhancements:**
- **Estimate new test runtime** based on similar tests:
  - File size heuristic (larger files ≈ more tests ≈ longer runtime)
  - Pattern matching (integration tests vs unit tests)
  - Directory-based averages (tests in `spec/integration/` vs `spec/models/`)
- **Auto-prune removed tests** from report during updates
- **Flag stale tests** where actual runtime differs significantly from report
- **Default estimation** for completely new test suites

**Testing Strategy:**
- Unit tests for estimation algorithms
- Integration tests with mock test suites
- Regression tests ensuring new tests still get run

### 2. More Sophisticated Balancing Algorithms (Lower Priority)

**Current State:**
- Greedy algorithm: assign each test to the lightest node
- Works well but can be improved

**Proposed Enhancements (Nice-to-have):**
- **Multi-pass balancing:**
  - Initial greedy assignment
  - Refinement pass to swap tests between nodes
  - Target: minimize max(node_times) - min(node_times)
- **Historical variance tracking:**
  - Track test runtime variance over multiple runs
  - Flag flaky/variable tests
  - Weight tests by variance in distribution

**Note:** The current greedy algorithm is pretty good. Better estimation (from #1) and automatic updates (from #3) will have bigger impact than tweaking the algorithm.

**Testing Strategy:**
- Property-based tests ensuring balance properties
- Benchmark tests comparing algorithms
- Tests with known-difficult distributions

### 3. Automatic Runtime Updates (Zero-Config, CI-Friendly)
**Current State:**
- Manual `KNAPSACK_GENERATE_REPORT=true` to regenerate
- Report must be committed to git
- No incremental updates

**NEW Design Philosophy:**
- **No git storage** - runtime data never goes in version control
- **Auto-detect environment** - local vs CI, no config needed
- **Always learning** - every run updates the cache automatically
- **Graceful degradation** - works great without cache, better with it

**Proposed Solution - Smart Cache Approach:**

#### Local Development
```
./tmp/.knapsack/
├── runtime.json          # Main runtime cache
├── runtime.json.lock     # Prevent concurrent writes
└── history/              # Optional: keep last N runs
    ├── 2025-10-24-001.json
    └── 2025-10-24-002.json
```

- Added to `.gitignore` automatically
- Merged after each test run
- Shared across branches
- Thread-safe updates

#### CI Environment (GitHub Actions)
```
┌─────────────────────────────────────────────┐
│  GitHub Actions Workflow                   │
│  ┌──────────────────────────────────────┐  │
│  │ Job: test (matrix: [0,1,2,3])        │  │
│  │ - Restore cache (automatic)          │  │
│  │ - Run tests (auto-tracks timing)     │  │
│  │ - Save node results to artifacts     │  │
│  └──────────────────────────────────────┘  │
│  ┌──────────────────────────────────────┐  │
│  │ Job: update-cache (depends on test)  │  │
│  │ - Download all node results          │  │
│  │ - Merge into unified cache           │  │
│  │ - Save cache for next run            │  │
│  └──────────────────────────────────────┘  │
└─────────────────────────────────────────────┘
```

#### Key Features:
- **Zero configuration** - auto-detects local vs CI
- **No git storage** - uses `./tmp` locally, artifacts in CI
- **Always on** - every run updates cache automatically
- **Smart messaging:**
  - First run (no cache): "⚡ Knapsack: Learning test timings... (this run will establish baseline)"
  - Subsequent runs: Silent (or verbose mode: "✓ Using cached timings from 150 tests")
  - After update: Silent (or verbose mode: "✓ Updated timings for 12 tests")
  - Poor balance detected: "ℹ Knapsack: Balance could improve after a few more runs"
- **Automatic merging** - collect runtimes from all parallel nodes
- **Incremental updates** - merge new data with existing cache
- **Smart fallback** - works without cache, just less optimized
- **Rolling average** - last 5 runs weighted by recency

#### Implementation Details:
```ruby
# ZERO CONFIG NEEDED - this just works:
# In spec_helper.rb or test_helper.rb:
require 'knapsack'
Knapsack::Adapters::RSpecAdapter.bind

# That's it! Everything else is automatic.

# Advanced users can configure:
Knapsack.configure do |config|
  # Storage (auto-detected by default)
  config.cache_dir = './tmp/.knapsack'  # local default
  config.ci_cache_adapter = :github_actions  # auto-detected

  # Update behavior (smart defaults)
  config.auto_update = true  # default: true
  config.update_strategy = :rolling_average  # default
  config.rolling_window = 5  # default: 5 runs

  # Messaging
  config.verbose = false  # default: false
  config.quiet = false    # default: false (shows important messages only)

  # Estimation for new tests
  config.estimate_new_tests = true  # default: true
  config.estimation_strategy = :smart  # file_size + directory_average
end

# Core implementation
class Knapsack::Cache
  # Auto-detects environment
  def self.storage_path
    if ci?
      ci_cache_path  # Uses CI-specific artifact location
    else
      './tmp/.knapsack/runtime.json'
    end
  end

  # Automatically called after each run
  def self.update(test_timings)
    lock do
      existing = load_cache || {}
      merged = RuntimeMerger.merge(existing, test_timings)
      save_cache(merged)
    end
  end

  # Load cache with graceful fallback
  def self.load
    load_cache || {}
  rescue => e
    log_info "No cache found, will learn from this run"
    {}
  end
end

# Runtime merging with outlier detection
class Knapsack::RuntimeMerger
  def self.merge(existing, new_timings)
    merged = existing.dup

    new_timings.each do |test_path, new_time|
      if existing[test_path]
        # Rolling average, weighted to recent
        merged[test_path] = weighted_average(
          existing[test_path],
          new_time,
          weight: 0.7  # 70% new, 30% old
        )
      else
        # New test
        merged[test_path] = new_time
      end
    end

    # Prune removed tests (not run in last N runs)
    prune_stale_tests(merged, new_timings)

    merged
  end

  def self.prune_stale_tests(merged, recent)
    # Mark tests not seen recently
    # Remove after they haven't been seen in 10+ runs
  end
end
```

#### GitHub Actions Integration:

**Option A: Simple (Cache Only - Fast Setup)**
```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        node: [0, 1, 2, 3]
    steps:
      - uses: actions/checkout@v4

      # Knapsack auto-detects and uses this cache
      - name: Cache Knapsack runtimes
        uses: actions/cache@v3
        with:
          path: tmp/.knapsack
          key: knapsack-${{ github.ref }}-${{ hashFiles('spec/**/*_spec.rb') }}
          restore-keys: |
            knapsack-${{ github.ref }}-
            knapsack-main-

      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          bundler-cache: true

      # That's it! Knapsack handles everything automatically
      - name: Run tests
        run: bundle exec rake knapsack:rspec
```

**Option B: Advanced (Artifact Merge - Most Accurate)**
```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        node: [0, 1, 2, 3]
    steps:
      - uses: actions/checkout@v4

      # Restore merged cache from previous run
      - name: Restore Knapsack cache
        uses: actions/cache/restore@v3
        with:
          path: tmp/.knapsack
          key: knapsack-merged-${{ github.sha }}
          restore-keys: knapsack-merged-

      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          bundler-cache: true

      # Knapsack auto-tracks and saves per-node results
      - name: Run tests
        run: bundle exec rake knapsack:rspec

      # Upload this node's timings for merging
      - name: Upload node timings
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: knapsack-node-${{ matrix.node }}
          path: tmp/.knapsack/node-${{ matrix.node }}.json
          retention-days: 1

  # Merge all node results into unified cache
  merge-cache:
    needs: test
    if: always()
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          bundler-cache: true

      # Download all node results
      - name: Download all node timings
        uses: actions/download-artifact@v4
        with:
          pattern: knapsack-node-*
          path: tmp/.knapsack/nodes

      # Knapsack merges automatically
      - name: Merge runtime data
        run: bundle exec rake knapsack:merge

      # Save merged cache for next run
      - name: Save merged cache
        uses: actions/cache/save@v3
        with:
          path: tmp/.knapsack
          key: knapsack-merged-${{ github.sha }}
```

**Most Common: Simple cache is usually enough!** The advanced option is only needed if you want the absolute best accuracy.

**Testing Strategy:**
- Unit tests for runtime merging logic
- Integration tests simulating multi-node scenarios
- Tests for artifact upload/download
- Fallback behavior tests
- Outlier detection tests

### 4. Integration with parallel_tests Gem (Optional Enhancement)

**Goal:** Work seamlessly with `parallel_tests` for local development

**Nice-to-have Features:**
- **Shared runtime format** - compatible with both gems
- **Environment variable compatibility**
- **Runtime report sharing** - parallel_tests can use knapsack cache

**Note:** This is lower priority. Getting 1 & 3 working perfectly is more important.

**Testing Strategy:**
- Integration tests with parallel_tests installed
- Format compatibility tests

## Implementation Phases

### Phase 1: Foundation - Auto-Caching Infrastructure ⭐ PRIORITY
**Goal:** Make runtime tracking completely automatic

- [ ] Create `Knapsack::Cache` class with auto-detection
- [ ] Implement local file cache in `./tmp/.knapsack/`
- [ ] Add `.gitignore` auto-update
- [ ] Implement thread-safe file locking
- [ ] Create CI environment detection
- [ ] Add GitHub Actions cache integration
- [ ] Implement basic runtime merging (weighted average)
- [ ] Add smart messaging (first run, subsequent runs)
- [ ] Comprehensive tests for cache operations

**Success Criteria:**
- Works locally with zero config
- Auto-saves timings after every run
- Loads cached timings automatically
- Never touches git

### Phase 2: Smart Test Estimation ⭐ PRIORITY
**Goal:** Handle new/removed tests intelligently

- [ ] Implement file size heuristics
- [ ] Add directory-based averaging
- [ ] Combine multiple estimation strategies
- [ ] Auto-prune removed tests from cache
- [ ] Flag stale tests (significant runtime change)
- [ ] Default estimation for brand new suites
- [ ] Test estimation accuracy against real data

**Success Criteria:**
- New tests get reasonable time estimates
- Removed tests don't clutter cache
- Estimates within 50% of actual (good enough for first pass)

### Phase 3: GitHub Actions Integration ⭐ PRIORITY
**Goal:** Make GHA setup trivial

- [ ] Create example workflows (simple + advanced)
- [ ] Implement artifact-based node result collection
- [ ] Add `rake knapsack:merge` task
- [ ] Test with actual GHA workflows
- [ ] Document setup process
- [ ] Add troubleshooting guide

**Success Criteria:**
- Simple workflow = 5 lines of YAML
- Works on first try
- Improves balance with each run

### Phase 4: Polish & Documentation
- [ ] Complete test coverage (>90%)
- [ ] Add verbose/quiet modes
- [ ] Improve error messages
- [ ] Migration guide from old knapsack
- [ ] Performance testing
- [ ] Real-world validation

### Phase 5: Advanced Features (Optional)
- [ ] Multi-pass balancing refinement
- [ ] Variance tracking for flaky tests
- [ ] parallel_tests compatibility
- [ ] Other CI providers (CircleCI, etc.)

## Key Design Principles

1. **Zero Config:** Works perfectly with defaults, configure only if needed
2. **Never Use Git:** Runtime data goes in `./tmp` (local) or cache/artifacts (CI)
3. **Auto-Everything:** Detects environment, updates cache, estimates new tests
4. **Fail Gracefully:** Works without cache, just less optimized
5. **Well-Tested:** Every feature has comprehensive tests (>90% coverage)
6. **Quiet by Default:** Only show messages when helpful (first run, issues)
7. **GitHub Actions First:** Optimize for GHA, support others
8. **Backward Compatible:** Existing reports still work (legacy mode)

## Configuration API

```ruby
# DEFAULT: No configuration needed! Just this in spec_helper.rb:
require 'knapsack'
Knapsack::Adapters::RSpecAdapter.bind

# OPTIONAL: Advanced configuration for power users
Knapsack.configure do |config|
  # Cache location (auto-detected by default)
  config.cache_dir = './tmp/.knapsack'  # default

  # Auto-update (should almost always be true)
  config.auto_update = true  # default: true
  config.update_strategy = :rolling_average  # default
  config.rolling_window = 5  # default: 5 runs

  # Messaging
  config.verbose = false  # default: false - show cache hits/misses
  config.quiet = false    # default: false - hide all non-error messages

  # New test estimation
  config.estimate_new_tests = true  # default: true
  config.estimation_strategy = :smart  # default: smart (combines file_size + directory_average)

  # Pruning
  config.auto_prune = true  # default: true - remove tests not seen in 10 runs
  config.prune_threshold = 10  # default: 10 runs
end

# For CI, environment variables work too:
# KNAPSACK_CACHE_DIR=./tmp/.knapsack
# KNAPSACK_VERBOSE=true
# KNAPSACK_AUTO_UPDATE=true (default)
```

## Success Metrics

- **Zero Config:** Works with `Knapsack::Adapters::RSpecAdapter.bind` and nothing else
- **Balance Quality:** Max node time - min node time < 10% of average (after 3-5 runs)
- **New Test Handling:** Estimation within 50% of actual runtime
- **Cache Reliability:** 99%+ successful cache operations
- **Test Coverage:** >90% line coverage for all new code
- **Performance:** Overhead < 2% of total test runtime
- **No Git Pollution:** Zero files checked into git (except initial setup)

## Open Questions

1. Should first run without cache show a message, or be silent?
   - **Proposal:** Show brief message on first run, silent after
2. How many runs to keep in rolling average?
   - **Proposal:** 5 runs, configurable
3. Should we auto-add `tmp/.knapsack` to `.gitignore`?
   - **Proposal:** Yes, with user confirmation on first run
4. What to do if cache is corrupted?
   - **Proposal:** Auto-delete, log warning, start fresh
5. Support other CI providers beyond GitHub Actions?
   - **Proposal:** Yes, but GHA first, then CircleCI/GitLab

## Non-Goals (Out of Scope)

- Dynamic queue mode (use knapsack_pro for this)
- Test analytics dashboard (keep it simple)
- Distributed test execution coordination
- Support for languages other than Ruby
- **Storing runtime data in git** (explicitly out of scope)
- Complex configuration (keep defaults simple)
- Manual report generation workflows
