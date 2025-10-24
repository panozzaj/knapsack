# Knapsack Enhanced - User Experience Flow

## The "Set it and Forget it" Promise

### Initial Setup (One Time, 2 minutes)

**Step 1: Install**
```ruby
# Gemfile
gem 'knapsack', git: 'https://github.com/YourOrg/knapsack'  # your fork
```

**Step 2: Setup test helper**
```ruby
# spec/spec_helper.rb (or rails_helper.rb)
require 'knapsack'
Knapsack::Adapters::RSpecAdapter.bind
```

**Step 3: Update GitHub Actions**
```yaml
# .github/workflows/test.yml
jobs:
  test:
    strategy:
      matrix:
        node: [0, 1, 2, 3]
    steps:
      - uses: actions/checkout@v4

      - name: Cache Knapsack
        uses: actions/cache@v3
        with:
          path: tmp/.knapsack
          key: knapsack-${{ hashFiles('spec/**/*') }}
          restore-keys: knapsack-

      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          bundler-cache: true

      - name: Run tests
        run: bundle exec rake knapsack:rspec
```

**That's it. Never touch it again.**

---

## What Happens Behind the Scenes

### First Local Run (No Cache)

```bash
$ bundle exec rspec spec/

⚡ Knapsack: No cache found - learning test timings from this run...
   This will establish a baseline for future parallel runs.

RSpec running...
[... all tests run normally ...]

Finished in 5 minutes 32 seconds

✓ Knapsack: Learned timings for 847 tests
  Saved to: tmp/.knapsack/runtime.json
  Next run will use these timings for better distribution
```

### Second Local Run (Cache Exists)

```bash
$ bundle exec rspec spec/

RSpec running...
[... all tests run normally ...]

Finished in 5 minutes 28 seconds
# Silent - everything just works
```

### With Verbose Mode

```bash
$ KNAPSACK_VERBOSE=true bundle exec rspec spec/

✓ Knapsack: Loaded timings for 847 tests from cache
  Cache age: 2 hours
  Estimated balance: excellent

RSpec running...
[... all tests run normally ...]

Finished in 5 minutes 31 seconds

✓ Knapsack: Updated timings for 12 tests (847 total)
  3 new tests detected - estimated using directory averages
  2 removed tests pruned from cache
```

### First CI Run (No Cache)

```
GitHub Actions output:

Run bundle exec rake knapsack:rspec

⚡ Knapsack: No cache found - learning test timings...
   Distribution will improve after this run.

[Node 0] Running 212 tests (estimated even split)
[Node 1] Running 212 tests (estimated even split)
[Node 2] Running 212 tests (estimated even split)
[Node 3] Running 211 tests (estimated even split)

Results:
[Node 0] Finished in 5m 45s  ← some variance expected
[Node 1] Finished in 4m 58s
[Node 2] Finished in 5m 12s
[Node 3] Finished in 5m 28s

✓ Cache saved for next run
```

### Subsequent CI Runs (Cache Exists)

```
GitHub Actions output:

Run bundle exec rake knapsack:rspec

[Node 0] Running 223 tests (optimized split)
[Node 1] Running 198 tests (optimized split)
[Node 2] Running 215 tests (optimized split)
[Node 3] Running 211 tests (optimized split)

Results:
[Node 0] Finished in 5m 02s  ← much better balance
[Node 1] Finished in 5m 01s
[Node 2] Finished in 5m 04s
[Node 3] Finished in 4m 59s

✓ Cache updated (Silent - no output unless verbose)
```

### After Adding New Tests

```bash
$ bundle exec rspec spec/

✓ Knapsack: Loaded timings for 847 tests
  3 new tests detected - estimating runtime...
  - spec/services/new_feature_spec.rb (est: 12s, based on spec/services/ avg)
  - spec/models/widget_spec.rb (est: 2s, based on file size)
  - spec/integration/complex_flow_spec.rb (est: 45s, based on spec/integration/ avg)

RSpec running...
[... all tests including new ones ...]

Finished in 5 minutes 42 seconds

✓ Updated timings for 850 tests
  New tests now have accurate timings for next run
```

### When Things Go Wrong (Corrupted Cache)

```bash
$ bundle exec rspec spec/

⚠ Knapsack: Cache corrupted - rebuilding...
  Deleted: tmp/.knapsack/runtime.json
  Will learn timings from this run.

RSpec running...
[... continues normally ...]
```

---

## Files Created (All in tmp/, never in git)

```
./tmp/.knapsack/
├── runtime.json              # Main cache (merged timings)
├── runtime.json.lock         # Prevents concurrent writes
└── .gitignore                # Auto-created: ignores this directory
```

**Note:** The `.knapsack` directory should be in your `.gitignore`:
```gitignore
# .gitignore
/tmp/
```

---

## What Users Never Have to Think About

✅ Generating reports manually
✅ Committing runtime data
✅ Regenerating when tests change
✅ Configuring CI-specific behavior
✅ Merging parallel node results
✅ Handling new/removed tests
✅ Cache invalidation
✅ Concurrent access to cache

## What Users Can Control (Optional)

```ruby
# spec/spec_helper.rb
Knapsack.configure do |config|
  config.verbose = true           # See what's happening
  config.cache_dir = 'custom/path'  # Change cache location
  config.rolling_window = 3       # Average last 3 runs instead of 5
end
```

Or via environment variables:
```bash
KNAPSACK_VERBOSE=true bundle exec rspec
KNAPSACK_CACHE_DIR=custom/path bundle exec rspec
```

---

## Troubleshooting

### "Tests aren't balanced well"
**Expected:** First 2-3 runs will establish accurate timings. Balance improves automatically.

### "Cache isn't persisting in CI"
**Check:** GitHub Actions cache configuration. Make sure `path: tmp/.knapsack` is set.

### "Some tests are missing"
**Impossible:** Knapsack never skips tests. It only distributes them. All tests always run.

### "I want to reset the cache"
```bash
# Locally:
rm -rf tmp/.knapsack

# CI: Delete the cache in GitHub Actions settings, or change the cache key
```

---

## Migration from Old Knapsack

**Old way:**
```ruby
# spec/spec_helper.rb
require 'knapsack'
Knapsack::Adapters::RSpecAdapter.bind

# Had to manually generate report:
# KNAPSACK_GENERATE_REPORT=true bundle exec rspec
# Then commit knapsack_rspec_report.json to git
```

**New way:**
```ruby
# spec/spec_helper.rb
require 'knapsack'
Knapsack::Adapters::RSpecAdapter.bind

# That's it! Everything else is automatic.
```

**Migration steps:**
1. Update to new knapsack version
2. Delete old `knapsack_rspec_report.json` from git
3. Remove from `.github/workflows` any report generation steps
4. Add cache configuration to workflow (see above)
5. Done! First run learns timings, subsequent runs use them.

---

## Summary

**Setup Time:** 2 minutes
**Maintenance Time:** 0 minutes
**Mental Overhead:** Zero
**Just Works™**
