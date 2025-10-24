require_relative 'spec_helper'

RSpec.describe 'Fast test 1' do
it 'test case 1' do
  sleep 0.05
  expect(true).to be true
end

it 'test case 2' do
  sleep 0.05
  expect(true).to be true
end

it 'test case 3' do
  sleep 0.07308390937453788
  expect(true).to be true
end

end

# Total: ~0.17s
