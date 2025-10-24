require_relative 'spec_helper'

RSpec.describe 'Slow test 10' do
it 'test case 1' do
  sleep 0.2
  expect(true).to be true
end

it 'test case 2' do
  sleep 0.21
  expect(true).to be true
end

it 'test case 3' do
  sleep 0.43
  expect(true).to be true
end

it 'test case 4' do
  sleep 0.26
  expect(true).to be true
end

it 'test case 5' do
  sleep 0.286369929984841
  expect(true).to be true
end

end

# Total: ~1.39s
