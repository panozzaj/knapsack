module Knapsack
  class CacheReporter
    class << self
      # Show appropriate message based on cache state
      def report_cache_status
        if Cache.exists?
          report_cache_loaded
        else
          report_no_cache
        end
      end

      # Report after cache is updated
      def report_cache_updated(test_count)
        return if quiet?
        return unless verbose?

        Knapsack.logger.info("✓ Updated cache with #{test_count} test timing(s)")
      end

      private

      def report_cache_loaded
        return if quiet?
        return unless verbose?

        cache_age = format_age(Cache.age)
        test_count = Cache.load.size

        Knapsack.logger.info("✓ Loaded timings for #{test_count} test(s) from cache (#{cache_age} old)")
      end

      def report_no_cache
        return if quiet?
        return unless should_show_messages?

        Knapsack.logger.info("⚡ Knapsack: No cache found - learning test timings from this run")
        Knapsack.logger.info("   This will establish a baseline for future parallel runs")
      end

      def format_age(seconds)
        return 'unknown' if seconds.nil?

        if seconds < 60
          "#{seconds.to_i}s"
        elsif seconds < 3600
          "#{(seconds / 60).to_i}m"
        elsif seconds < 86400
          "#{(seconds / 3600).to_i}h"
        else
          "#{(seconds / 86400).to_i}d"
        end
      end

      def quiet?
        ENV['KNAPSACK_QUIET'] == 'true'
      end

      def verbose?
        ENV['KNAPSACK_VERBOSE'] == 'true'
      end

      def should_show_messages?
        # Only show messages in CI environment or if explicitly enabled
        # This prevents cluttering test output during local development
        ci_environment? || verbose? || ENV['KNAPSACK_SHOW_MESSAGES'] == 'true'
      end

      def ci_environment?
        # Common CI environment variables
        ENV['CI'] == 'true' ||
          ENV['CONTINUOUS_INTEGRATION'] == 'true' ||
          ENV['GITHUB_ACTIONS'] == 'true' ||
          ENV['CIRCLECI'] == 'true' ||
          ENV['TRAVIS'] == 'true' ||
          ENV['GITLAB_CI'] == 'true' ||
          ENV['BUILDKITE'] == 'true'
      end
    end
  end
end
