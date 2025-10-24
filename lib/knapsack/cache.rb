require 'json'
require 'fileutils'

module Knapsack
  class Cache
    class << self
      # Auto-detect and return the appropriate cache directory
      def cache_dir
        @cache_dir ||= ENV['KNAPSACK_CACHE_DIR'] || default_cache_dir
      end

      def cache_dir=(dir)
        @cache_dir = dir
      end

      # Main cache file path
      def cache_path
        File.join(cache_dir, 'runtime.json')
      end

      # Lock file path for thread-safe operations
      def lock_path
        "#{cache_path}.lock"
      end

      # Load cached runtime data with graceful fallback
      def load
        lock_for_read do
          load_without_lock
        end
      end

      # Save runtime data to cache
      def save(data)
        ensure_cache_dir_exists

        lock_for_write do
          save_without_lock(data)
        end
      rescue => e
        Knapsack.logger.warn("Failed to save cache: #{e.message}")
      end

      # Update cache with new timing data
      # Thread-safe: loads cache inside write lock to prevent data loss
      def update(new_timings)
        return if new_timings.empty?

        lock_for_write do
          # Reload cache inside lock to catch any concurrent updates
          existing = load_without_lock
          merged = RuntimeMerger.merge(existing, new_timings)
          save_without_lock(merged)

          log_cache_update(existing, new_timings, merged)
        end
      end

      # Check if cache exists and is valid
      def exists?
        File.exist?(cache_path)
      end

      # Delete the cache (for reset/corruption)
      def delete_cache
        FileUtils.rm_f(cache_path)
        FileUtils.rm_f(lock_path)
      end

      # Get cache age in seconds
      def age
        return nil unless exists?
        Time.now - File.mtime(cache_path)
      end

      private

      # Load without locking (internal use only - caller must hold lock)
      def load_without_lock
        return {} unless File.exist?(cache_path)

        JSON.parse(File.read(cache_path))
      rescue JSON::ParserError => e
        Knapsack.logger.warn("Cache corrupted, rebuilding: #{e.message}")
        delete_cache
        {}
      rescue => e
        Knapsack.logger.debug("No cache found: #{e.message}")
        {}
      end

      # Save without locking (internal use only - caller must hold lock)
      def save_without_lock(data)
        File.write(cache_path, JSON.pretty_generate(data))
      end

      def default_cache_dir
        File.join('.', 'tmp', '.knapsack')
      end

      def ensure_cache_dir_exists
        FileUtils.mkdir_p(cache_dir) unless Dir.exist?(cache_dir)
        ensure_gitignore
      end

      def ensure_gitignore
        gitignore_path = File.join(cache_dir, '.gitignore')
        return if File.exist?(gitignore_path)

        File.write(gitignore_path, "*\n")
      rescue => e
        # Non-critical, just log
        Knapsack.logger.debug("Could not create .gitignore: #{e.message}")
      end

      def lock_for_read(&block)
        # Use shared lock for reads to allow concurrent reads
        ensure_cache_dir_exists

        File.open(lock_path, File::RDWR | File::CREAT, 0644) do |lock_file|
          lock_file.flock(File::LOCK_SH)  # Shared lock
          result = block.call
          lock_file.flock(File::LOCK_UN)
          result
        end
      rescue => e
        Knapsack.logger.debug("Lock operation failed: #{e.message}")
        # Proceed without lock if locking fails
        block.call
      end

      def lock_for_write(&block)
        # File-based locking for thread safety
        ensure_cache_dir_exists

        File.open(lock_path, File::RDWR | File::CREAT, 0644) do |lock_file|
          lock_file.flock(File::LOCK_EX)
          result = block.call
          lock_file.flock(File::LOCK_UN)
          result
        end
      rescue => e
        Knapsack.logger.debug("Lock operation failed: #{e.message}")
        # Proceed without lock if locking fails
        block.call
      end

      def log_cache_update(existing, new_timings, merged)
        return unless verbose?

        new_tests = new_timings.keys - existing.keys
        updated_tests = new_timings.keys & existing.keys

        if new_tests.any?
          Knapsack.logger.info("✓ Added #{new_tests.size} new test(s) to cache")
        end

        if updated_tests.any?
          Knapsack.logger.info("✓ Updated timings for #{updated_tests.size} test(s)")
        end

        Knapsack.logger.info("✓ Cache now contains #{merged.size} test(s)")
      end

      def verbose?
        ENV['KNAPSACK_VERBOSE'] == 'true'
      end
    end
  end
end
