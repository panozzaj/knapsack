describe Knapsack::Cache do
  let(:cache_dir) { 'tmp/test_cache' }
  let(:cache_path) { File.join(cache_dir, 'runtime.json') }

  after do
    FileUtils.rm_rf(cache_dir) if Dir.exist?(cache_dir)
    described_class.instance_variable_set(:@cache_dir, nil)
  end

  describe '.cache_dir' do
    context 'when KNAPSACK_CACHE_DIR is set' do
      around do |example|
        ClimateControl.modify(KNAPSACK_CACHE_DIR: 'custom/cache/dir') do
          example.run
        end
      end

      it 'uses the environment variable' do
        expect(described_class.cache_dir).to eq('custom/cache/dir')
      end
    end

    context 'when KNAPSACK_CACHE_DIR is not set' do
      it 'uses the default directory' do
        expect(described_class.cache_dir).to eq('./tmp/.knapsack')
      end
    end
  end

  # For all tests that need the cache directory set up
  context 'with test cache directory' do
    before do
      FileUtils.rm_rf(cache_dir)
      described_class.cache_dir = cache_dir
    end

    describe '.cache_path' do
      it 'returns the full path to the cache file' do
        expect(described_class.cache_path).to eq(File.join(cache_dir, 'runtime.json'))
      end
    end

    describe '.load' do
    context 'when cache file does not exist' do
      it 'returns an empty hash' do
        expect(described_class.load).to eq({})
      end
    end

    context 'when cache file exists' do
      let(:cached_data) do
        {
          'spec/models/user_spec.rb' => 1.5,
          'spec/controllers/users_controller_spec.rb' => 2.3
        }
      end

      before do
        described_class.save(cached_data)
      end

      it 'loads and parses the cache file' do
        expect(described_class.load).to eq(cached_data)
      end
    end

    context 'when cache file is corrupted' do
      before do
        FileUtils.mkdir_p(cache_dir)
        File.write(cache_path, 'invalid json{{{')
      end

      it 'returns an empty hash' do
        expect(described_class.load).to eq({})
      end

      it 'deletes the corrupted cache' do
        described_class.load
        expect(File.exist?(cache_path)).to be false
      end

      it 'logs a warning' do
        expect(Knapsack.logger).to receive(:warn).with(/Cache corrupted/)
        described_class.load
      end
    end
  end

  describe '.save' do
    let(:data) do
      {
        'spec/models/user_spec.rb' => 1.5,
        'spec/controllers/users_controller_spec.rb' => 2.3
      }
    end

    it 'creates the cache directory if it does not exist' do
      expect(Dir.exist?(cache_dir)).to be false
      described_class.save(data)
      expect(Dir.exist?(cache_dir)).to be true
    end

    it 'writes the data to the cache file as JSON' do
      described_class.save(data)
      expect(File.exist?(cache_path)).to be true
      expect(JSON.parse(File.read(cache_path))).to eq(data)
    end

    it 'creates a .gitignore file in the cache directory' do
      described_class.save(data)
      gitignore_path = File.join(cache_dir, '.gitignore')
      expect(File.exist?(gitignore_path)).to be true
      expect(File.read(gitignore_path)).to eq("*\n")
    end

    context 'when save fails' do
      before do
        allow(File).to receive(:write).and_raise(Errno::EACCES, 'Permission denied')
      end

      it 'logs a warning and does not raise' do
        expect(Knapsack.logger).to receive(:warn).with(/Failed to save cache/)
        expect { described_class.save(data) }.not_to raise_error
      end
    end
  end

  describe '.update' do
    let(:existing_data) do
      {
        'spec/models/user_spec.rb' => 1.0,
        'spec/models/post_spec.rb' => 2.0
      }
    end

    let(:new_timings) do
      {
        'spec/models/user_spec.rb' => 1.5,
        'spec/models/widget_spec.rb' => 0.8
      }
    end

    before do
      described_class.save(existing_data)
    end

    it 'merges new timings with existing cache' do
      described_class.update(new_timings)
      result = described_class.load

      # user_spec should be updated with weighted average
      expect(result['spec/models/user_spec.rb']).to be_within(0.01).of(1.35) # 70% of 1.5 + 30% of 1.0

      # post_spec should remain unchanged
      expect(result['spec/models/post_spec.rb']).to eq(2.0)

      # widget_spec should be added
      expect(result['spec/models/widget_spec.rb']).to eq(0.8)
    end

    it 'saves the merged data' do
      described_class.update(new_timings)
      expect(File.exist?(cache_path)).to be true
    end

    context 'when new_timings is empty' do
      it 'does not update the cache' do
        original_mtime = File.mtime(cache_path)
        sleep 0.01 # Ensure time difference
        described_class.update({})
        expect(File.mtime(cache_path)).to eq(original_mtime)
      end
    end
  end

  describe '.exists?' do
    context 'when cache file exists' do
      before do
        described_class.save({'test' => 1.0})
      end

      it 'returns true' do
        expect(described_class.exists?).to be true
      end
    end

    context 'when cache file does not exist' do
      it 'returns false' do
        expect(described_class.exists?).to be false
      end
    end
  end

  describe '.delete_cache' do
    before do
      described_class.save({'test' => 1.0})
    end

    it 'deletes the cache file' do
      expect(File.exist?(cache_path)).to be true
      described_class.delete_cache
      expect(File.exist?(cache_path)).to be false
    end

    it 'deletes the lock file if it exists' do
      lock_path = described_class.lock_path
      FileUtils.touch(lock_path)
      expect(File.exist?(lock_path)).to be true
      described_class.delete_cache
      expect(File.exist?(lock_path)).to be false
    end
  end

  describe '.age' do
    context 'when cache exists' do
      before do
        described_class.save({'test' => 1.0})
      end

      it 'returns the age in seconds' do
        age = described_class.age
        expect(age).to be_a(Numeric)
        expect(age).to be >= 0
        expect(age).to be < 1 # Should be very recent
      end
    end

    context 'when cache does not exist' do
      it 'returns nil' do
        expect(described_class.age).to be_nil
      end
    end
  end

    describe 'thread safety' do
      it 'handles concurrent writes safely' do
        threads = 10.times.map do |i|
          Thread.new do
            described_class.update({"test_#{i}" => i.to_f})
          end
        end

        threads.each(&:join)

        result = described_class.load
        expect(result.keys.size).to be > 0
      end
    end
  end
end
