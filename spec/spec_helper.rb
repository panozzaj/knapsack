require 'rspec/its'
require 'spinach'

require 'timecop'
Timecop.safe_mode = true

require 'climate_control'

require 'knapsack'

Dir["#{Knapsack.root}/spec/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  # Silence logger output in tests by stubbing the underlying puts
  # Tests can still spy on logger.debug/info/warn methods
  config.before(:each) do
    # Stub the logger's internal puts calls to suppress output
    allow(Knapsack.logger).to receive(:puts)
  end
end

RSpec.configure do |config|
  config.order = :random
  config.mock_with :rspec do |mocks|
    mocks.syntax = :expect
    mocks.verify_partial_doubles = true
  end

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:each) do
    if RSpec.current_example.metadata[:clear_tmp]
      FileUtils.mkdir_p(File.join(Knapsack.root, 'tmp'))
    end
  end

  config.after(:each) do
    if RSpec.current_example.metadata[:clear_tmp]
      FileUtils.rm_r(File.join(Knapsack.root, 'tmp'))
    end
  end
end
