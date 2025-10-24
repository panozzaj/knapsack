require_relative 'spec_helper'

RSpec.describe 'Fast test 3' do
it 'test case 1' do
  sleep 0.08
  expect(true).to be true
end

it 'test case 2' do
  sleep 0.04
  expect(true).to be true
end

it 'test case 3' do
  sleep 0.09
  expect(true).to be true
end

it 'test case 4' do
  sleep 0.07723852168129292
  expect(true).to be true
end

end

# Total: ~0.29s
