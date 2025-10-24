require_relative 'spec_helper'

RSpec.describe 'Ultra fast test 1' do
it 'test case 1' do
  sleep 0.04
  expect(true).to be true
end

it 'test case 2' do
  sleep 0.04276523897348348
  expect(true).to be true
end

end

# Total: ~0.08s
