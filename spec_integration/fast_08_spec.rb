require_relative 'spec_helper'

RSpec.describe 'Fast test 8' do
it 'test case 1' do
  sleep 0.07
  expect(true).to be true
end

it 'test case 2' do
  sleep 0.09
  expect(true).to be true
end

it 'test case 3' do
  sleep 0.08
  expect(true).to be true
end

it 'test case 4' do
  sleep 0.03681493093747672
  expect(true).to be true
end

end

# Total: ~0.28s
