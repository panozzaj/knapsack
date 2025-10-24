require_relative 'spec_helper'

RSpec.describe 'Ultra fast test 3' do
it 'test case 1' do
  sleep 0.05
  expect(true).to be true
end

it 'test case 2' do
  sleep 0.04468817779871295
  expect(true).to be true
end

end

# Total: ~0.09s
