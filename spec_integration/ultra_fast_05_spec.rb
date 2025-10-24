require_relative 'spec_helper'

RSpec.describe 'Ultra fast test 5' do
it 'test case 1' do
  sleep 0.02
  expect(true).to be true
end

it 'test case 2' do
  sleep 0.03423251811956124
  expect(true).to be true
end

end

# Total: ~0.05s
