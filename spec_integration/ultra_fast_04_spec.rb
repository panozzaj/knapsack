require_relative 'spec_helper'

RSpec.describe 'Ultra fast test 4' do
it 'test case 1' do
  sleep 0.02
  expect(true).to be true
end

it 'test case 2' do
  sleep 0.02
  expect(true).to be true
end

it 'test case 3' do
  sleep 0.026791499488536822
  expect(true).to be true
end

end

# Total: ~0.07s
