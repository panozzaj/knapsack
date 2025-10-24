#!/usr/bin/env ruby
# Integration test runner for Knapsack cache system

require 'json'
require 'fileutils'

CACHE_DIR = './tmp/.knapsack'
CACHE_FILE = File.join(CACHE_DIR, 'runtime.json')
NUM_NODES = 8
SPEC_PATTERN = 'spec_integration/**/*_spec.rb'

def banner(text)
  puts "\n" + ("=" * 80)
  puts text.center(80)
  puts ("=" * 80) + "\n\n"
end

def run_node(node_index, run_number)
  start_time = Time.now

  cmd = "CI_NODE_TOTAL=#{NUM_NODES} CI_NODE_INDEX=#{node_index} " +
        "KNAPSACK_TEST_FILE_PATTERN='#{SPEC_PATTERN}' " +
        "bundle exec rake knapsack:rspec 2>&1"

  output = `#{cmd}`

  end_time = Time.now
  duration = end_time - start_time

  {
    node: node_index,
    run: run_number,
    duration: duration,
    output: output
  }
end

def calculate_balance_stats(results)
  durations = results.map { |r| r[:duration] }
  min = durations.min
  max = durations.max
  avg = durations.sum / durations.size
  variance = max - min
  variance_pct = (variance / avg * 100).round(1)

  {
    min: min,
    max: max,
    avg: avg,
    variance: variance,
    variance_pct: variance_pct
  }
end

def print_results(results, stats, run_number)
  puts "\nRun #{run_number} Results:"
  puts "-" * 80
  results.sort_by { |r| r[:node] }.each do |result|
    deviation = ((result[:duration] - stats[:avg]) / stats[:avg] * 100).round(1)
    deviation_str = deviation >= 0 ? "+#{deviation}%" : "#{deviation}%"

    puts sprintf("  Node %d: %.2fs (%s from average)",
      result[:node],
      result[:duration],
      deviation_str
    )
  end

  puts "\n  Statistics:"
  puts sprintf("    Min:      %.2fs", stats[:min])
  puts sprintf("    Max:      %.2fs", stats[:max])
  puts sprintf("    Average:  %.2fs", stats[:avg])
  puts sprintf("    Variance: %.2fs (%.1f%%)", stats[:variance], stats[:variance_pct])
  puts "-" * 80
end

def check_cache
  if File.exist?(CACHE_FILE)
    cache = JSON.parse(File.read(CACHE_FILE))
    total_cached_time = cache.values.sum
    puts "\n✓ Cache exists with #{cache.size} test file timings"
    puts sprintf("  Total cached time: %.2fs", total_cached_time)
    puts "\n  Top 10 slowest tests:"
    cache.sort_by { |_k, v| -v }.first(10).each do |path, time|
      puts sprintf("    - %-55s %.3fs", path.split('/').last, time)
    end
  else
    puts "\n✗ No cache found"
  end
end

# Main test execution
banner("Knapsack Integration Test")

# Count test files
test_files = Dir.glob(SPEC_PATTERN).reject { |f| f.include?('spec_helper') }
puts "Test Suite Stats:"
puts "  Total test files: #{test_files.size}"
puts "  Nodes: #{NUM_NODES}"
puts "  Expected files per node: ~#{(test_files.size.to_f / NUM_NODES).round(1)}"
puts ""

# Clean up cache before starting
puts "Cleaning up cache..."
FileUtils.rm_rf(CACHE_DIR)
puts "✓ Cache cleaned\n"

# Run 1: No cache (baseline)
banner("RUN 1: No Cache (Baseline)")
check_cache

puts "\nRunning tests on #{NUM_NODES} nodes in parallel..."
run1_results = []
threads = NUM_NODES.times.map do |i|
  Thread.new { run1_results << run_node(i, 1) }
end
threads.each(&:join)

run1_stats = calculate_balance_stats(run1_results)
print_results(run1_results, run1_stats, 1)
check_cache

# Run 2: With cache (should be better balanced)
banner("RUN 2: With Cache (Should Improve)")
check_cache

puts "\nRunning tests on #{NUM_NODES} nodes in parallel..."
run2_results = []
threads = NUM_NODES.times.map do |i|
  Thread.new { run2_results << run_node(i, 2) }
end
threads.each(&:join)

run2_stats = calculate_balance_stats(run2_results)
print_results(run2_results, run2_stats, 2)
check_cache

# Comparison
banner("COMPARISON")

improvement = ((run1_stats[:variance_pct] - run2_stats[:variance_pct]) / run1_stats[:variance_pct] * 100).round(1)

puts "\nBalance Improvement:"
puts sprintf("  Run 1 variance: %.1f%%", run1_stats[:variance_pct])
puts sprintf("  Run 2 variance: %.1f%%", run2_stats[:variance_pct])
puts sprintf("  Improvement:    %.1f%%", improvement)

if run2_stats[:variance_pct] < run1_stats[:variance_pct]
  puts "\n✅ SUCCESS: Run 2 is better balanced!"
else
  puts "\n⚠️  WARNING: Run 2 did not improve balance"
end

# Success criteria
SUCCESS_THRESHOLD = 20.0 # Max 20% variance is acceptable
if run2_stats[:variance_pct] <= SUCCESS_THRESHOLD
  puts "\n✅ PASS: Variance within acceptable threshold (#{SUCCESS_THRESHOLD}%)"
  exit 0
else
  puts "\n❌ FAIL: Variance (#{run2_stats[:variance_pct]}%) exceeds threshold (#{SUCCESS_THRESHOLD}%)"
  exit 1
end
