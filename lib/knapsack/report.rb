module Knapsack
  class Report
    include Singleton

    def config(args={})
      @config ||= args
      @config.merge!(args)
    end

    def report_path
      config[:report_path] || raise('Missing report_path')
    end

    def test_file_pattern
      config[:test_file_pattern] || raise('Missing test_file_pattern')
    end

    def save
      File.open(report_path, 'w+') do |f|
        f.write(report_json)
      end
    end

    def open
      # Try cache first (auto-updated, no git pollution)
      cached = Knapsack::Cache.load
      return cached unless cached.empty?

      # Fallback to traditional report file (legacy mode)
      report = File.read(report_path)
      JSON.parse(report)
    rescue Errno::ENOENT
      # No report file and no cache - return empty hash
      # Knapsack will use leftover distributor for all tests
      {}
    end

    private

    def report_json
      Presenter.report_json
    end
  end
end
