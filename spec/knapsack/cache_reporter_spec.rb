describe Knapsack::CacheReporter do
  describe '.report_cache_status' do
    context 'when cache exists' do
      before do
        allow(Knapsack::Cache).to receive(:exists?).and_return(true)
        allow(Knapsack::Cache).to receive(:age).and_return(3600) # 1 hour
        allow(Knapsack::Cache).to receive(:load).and_return({
          'spec/models/user_spec.rb' => 1.5,
          'spec/models/post_spec.rb' => 2.0
        })
      end

      context 'in quiet mode' do
        around do |example|
          ClimateControl.modify(KNAPSACK_QUIET: 'true') do
            example.run
          end
        end

        it 'does not log anything' do
          expect(Knapsack.logger).not_to receive(:info)
          described_class.report_cache_status
        end
      end

      context 'in normal mode (not verbose)' do
        it 'does not log anything' do
          expect(Knapsack.logger).not_to receive(:info)
          described_class.report_cache_status
        end
      end

      context 'in verbose mode' do
        around do |example|
          ClimateControl.modify(KNAPSACK_VERBOSE: 'true') do
            example.run
          end
        end

        it 'logs cache information' do
          expect(Knapsack.logger).to receive(:info).with(/Loaded timings for 2 test.*1h old/)
          described_class.report_cache_status
        end
      end
    end

    context 'when cache does not exist' do
      before do
        allow(Knapsack::Cache).to receive(:exists?).and_return(false)
      end

      context 'in quiet mode' do
        around do |example|
          ClimateControl.modify(KNAPSACK_QUIET: 'true') do
            example.run
          end
        end

        it 'does not log anything' do
          expect(Knapsack.logger).not_to receive(:info)
          described_class.report_cache_status
        end
      end

      context 'in normal mode (not CI)' do
        it 'does not show messages (prevents test output clutter)' do
          expect(Knapsack.logger).not_to receive(:info)
          described_class.report_cache_status
        end
      end

      context 'in CI environment' do
        around do |example|
          ClimateControl.modify(CI: 'true') do
            example.run
          end
        end

        it 'shows helpful first-run message' do
          expect(Knapsack.logger).to receive(:info).with(/No cache found/)
          expect(Knapsack.logger).to receive(:info).with(/establish a baseline/)
          described_class.report_cache_status
        end
      end
    end
  end

  describe '.report_cache_updated' do
    context 'in quiet mode' do
      around do |example|
        ClimateControl.modify(KNAPSACK_QUIET: 'true') do
          example.run
        end
      end

      it 'does not log anything' do
        expect(Knapsack.logger).not_to receive(:info)
        described_class.report_cache_updated(10)
      end
    end

    context 'in normal mode' do
      it 'does not log anything' do
        expect(Knapsack.logger).not_to receive(:info)
        described_class.report_cache_updated(10)
      end
    end

    context 'in verbose mode' do
      around do |example|
        ClimateControl.modify(KNAPSACK_VERBOSE: 'true') do
          example.run
        end
      end

      it 'logs update information' do
        expect(Knapsack.logger).to receive(:info).with(/Updated cache with 10 test/)
        described_class.report_cache_updated(10)
      end
    end
  end

  describe 'age formatting' do
    it 'formats seconds' do
      allow(Knapsack::Cache).to receive(:exists?).and_return(true)
      allow(Knapsack::Cache).to receive(:age).and_return(45)
      allow(Knapsack::Cache).to receive(:load).and_return({'test' => 1.0})

      expect(Knapsack.logger).to receive(:info).with(/45s old/)

      ClimateControl.modify(KNAPSACK_VERBOSE: 'true') do
        described_class.report_cache_status
      end
    end

    it 'formats minutes' do
      allow(Knapsack::Cache).to receive(:exists?).and_return(true)
      allow(Knapsack::Cache).to receive(:age).and_return(180) # 3 minutes
      allow(Knapsack::Cache).to receive(:load).and_return({'test' => 1.0})

      expect(Knapsack.logger).to receive(:info).with(/3m old/)

      ClimateControl.modify(KNAPSACK_VERBOSE: 'true') do
        described_class.report_cache_status
      end
    end

    it 'formats hours' do
      allow(Knapsack::Cache).to receive(:exists?).and_return(true)
      allow(Knapsack::Cache).to receive(:age).and_return(7200) # 2 hours
      allow(Knapsack::Cache).to receive(:load).and_return({'test' => 1.0})

      expect(Knapsack.logger).to receive(:info).with(/2h old/)

      ClimateControl.modify(KNAPSACK_VERBOSE: 'true') do
        described_class.report_cache_status
      end
    end

    it 'formats days' do
      allow(Knapsack::Cache).to receive(:exists?).and_return(true)
      allow(Knapsack::Cache).to receive(:age).and_return(172800) # 2 days
      allow(Knapsack::Cache).to receive(:load).and_return({'test' => 1.0})

      expect(Knapsack.logger).to receive(:info).with(/2d old/)

      ClimateControl.modify(KNAPSACK_VERBOSE: 'true') do
        described_class.report_cache_status
      end
    end
  end
end
