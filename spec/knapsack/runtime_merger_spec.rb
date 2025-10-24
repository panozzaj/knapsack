describe Knapsack::RuntimeMerger do
  describe '.merge' do
    context 'with no existing data' do
      it 'returns the new timings' do
        existing = {}
        new_timings = {
          'spec/models/user_spec.rb' => 1.5,
          'spec/models/post_spec.rb' => 2.0
        }

        result = described_class.merge(existing, new_timings)

        expect(result).to eq(new_timings)
      end
    end

    context 'with existing data' do
      let(:existing) do
        {
          'spec/models/user_spec.rb' => 1.0,
          'spec/models/post_spec.rb' => 2.0
        }
      end

      context 'updating existing tests' do
        it 'uses weighted average favoring new timings (70% new, 30% old)' do
          new_timings = {
            'spec/models/user_spec.rb' => 2.0
          }

          result = described_class.merge(existing, new_timings)

          # Expected: (2.0 * 0.7) + (1.0 * 0.3) = 1.4 + 0.3 = 1.7
          expect(result['spec/models/user_spec.rb']).to be_within(0.01).of(1.7)
        end

        it 'keeps tests that were not updated' do
          new_timings = {
            'spec/models/user_spec.rb' => 2.0
          }

          result = described_class.merge(existing, new_timings)

          expect(result['spec/models/post_spec.rb']).to eq(2.0)
        end
      end

      context 'adding new tests' do
        it 'adds new tests to the result' do
          new_timings = {
            'spec/models/widget_spec.rb' => 0.5
          }

          result = described_class.merge(existing, new_timings)

          expect(result['spec/models/widget_spec.rb']).to eq(0.5)
          expect(result['spec/models/user_spec.rb']).to eq(1.0)
          expect(result['spec/models/post_spec.rb']).to eq(2.0)
        end
      end

      context 'mixed update and new tests' do
        it 'handles both correctly' do
          new_timings = {
            'spec/models/user_spec.rb' => 2.0,      # update
            'spec/models/widget_spec.rb' => 0.5     # new
          }

          result = described_class.merge(existing, new_timings)

          expect(result['spec/models/user_spec.rb']).to be_within(0.01).of(1.7)
          expect(result['spec/models/post_spec.rb']).to eq(2.0)
          expect(result['spec/models/widget_spec.rb']).to eq(0.5)
        end
      end
    end

    context 'edge cases' do
      it 'handles zero timing values' do
        existing = {'spec/fast_spec.rb' => 0.0}
        new_timings = {'spec/fast_spec.rb' => 0.0}

        result = described_class.merge(existing, new_timings)

        expect(result['spec/fast_spec.rb']).to eq(0.0)
      end

      it 'handles very large timing values' do
        existing = {'spec/slow_spec.rb' => 999.9}
        new_timings = {'spec/slow_spec.rb' => 1000.0}

        result = described_class.merge(existing, new_timings)

        # (1000.0 * 0.7) + (999.9 * 0.3) = 700 + 299.97 = 999.97
        expect(result['spec/slow_spec.rb']).to be_within(0.01).of(999.97)
      end

      it 'does not modify the original existing hash' do
        existing = {'spec/test_spec.rb' => 1.0}
        new_timings = {'spec/test_spec.rb' => 2.0}

        described_class.merge(existing, new_timings)

        expect(existing['spec/test_spec.rb']).to eq(1.0)
      end
    end

    describe 'weighted average calculation' do
      it 'weights recent runs at 70%' do
        existing = {'test.rb' => 10.0}
        new_timings = {'test.rb' => 20.0}

        result = described_class.merge(existing, new_timings)

        # (20 * 0.7) + (10 * 0.3) = 14 + 3 = 17
        expect(result['test.rb']).to eq(17.0)
      end

      it 'converges toward new values over multiple runs' do
        timings = {'test.rb' => 10.0}

        # Simulate 5 runs all reporting 20.0
        5.times do
          timings = described_class.merge(timings, {'test.rb' => 20.0})
        end

        # Should be very close to 20.0 after 5 iterations
        expect(timings['test.rb']).to be_within(0.5).of(20.0)
      end
    end
  end
end
