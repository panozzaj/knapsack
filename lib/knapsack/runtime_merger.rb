module Knapsack
  class RuntimeMerger
    class << self
      # Merge existing runtime data with new timings
      # Uses weighted average favoring recent runs
      def merge(existing, new_timings)
        merged = existing.dup

        new_timings.each do |test_path, new_time|
          merged[test_path] = if existing[test_path]
            weighted_average(existing[test_path], new_time)
          else
            new_time
          end
        end

        prune_stale_tests(merged, new_timings) if auto_prune?

        merged
      end

      private

      # Weighted average: favor recent runs (70%) over historical (30%)
      def weighted_average(old_time, new_time, weight: 0.7)
        (new_time * weight) + (old_time * (1.0 - weight))
      end

      # Remove tests that haven't been seen recently
      def prune_stale_tests(merged, recent_timings)
        # For now, we don't prune on every run
        # This will be enhanced in Phase 2 with better tracking
        # of how many runs a test has been missing
        merged
      end

      def auto_prune?
        ENV['KNAPSACK_AUTO_PRUNE'] != 'false'
      end
    end
  end
end
