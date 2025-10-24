describe Knapsack::CacheReporter do
  describe 'CI environment detection' do
    context 'when not in CI' do
      it 'does not show first-run message by default' do
        allow(Knapsack::Cache).to receive(:exists?).and_return(false)

        expect(Knapsack.logger).not_to receive(:info)
        described_class.report_cache_status
      end
    end

    context 'when in CI (CI=true)' do
      around do |example|
        ClimateControl.modify(CI: 'true') do
          example.run
        end
      end

      it 'shows first-run message' do
        allow(Knapsack::Cache).to receive(:exists?).and_return(false)

        expect(Knapsack.logger).to receive(:info).with(/No cache found/)
        expect(Knapsack.logger).to receive(:info).with(/establish a baseline/)
        described_class.report_cache_status
      end
    end

    context 'when in GitHub Actions' do
      around do |example|
        ClimateControl.modify(GITHUB_ACTIONS: 'true') do
          example.run
        end
      end

      it 'shows first-run message' do
        allow(Knapsack::Cache).to receive(:exists?).and_return(false)

        expect(Knapsack.logger).to receive(:info).with(/No cache found/)
        expect(Knapsack.logger).to receive(:info).with(/establish a baseline/)
        described_class.report_cache_status
      end
    end

    context 'when KNAPSACK_SHOW_MESSAGES is true' do
      around do |example|
        ClimateControl.modify(KNAPSACK_SHOW_MESSAGES: 'true') do
          example.run
        end
      end

      it 'shows first-run message even outside CI' do
        allow(Knapsack::Cache).to receive(:exists?).and_return(false)

        expect(Knapsack.logger).to receive(:info).with(/No cache found/)
        expect(Knapsack.logger).to receive(:info).with(/establish a baseline/)
        described_class.report_cache_status
      end
    end

    context 'in verbose mode' do
      around do |example|
        ClimateControl.modify(KNAPSACK_VERBOSE: 'true') do
          example.run
        end
      end

      it 'shows messages even outside CI' do
        allow(Knapsack::Cache).to receive(:exists?).and_return(false)

        expect(Knapsack.logger).to receive(:info).with(/No cache found/)
        expect(Knapsack.logger).to receive(:info).with(/establish a baseline/)
        described_class.report_cache_status
      end
    end
  end
end
