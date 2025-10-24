require_relative 'spec_helper'

RSpec.describe 'Fast test 9' do
it 'test case 1' do
  sleep 0.08
  expect(true).to be true
end

it 'test case 2' do
  sleep 0.08
  expect(true).to be true
end

it 'test case 3' do
  sleep 0.0779685011239631
  expect(true).to be true
end

end

# Total: ~0.24s
