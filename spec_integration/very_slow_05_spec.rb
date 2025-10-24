require_relative 'spec_helper'

RSpec.describe 'Very slow test 5' do
it 'test case 1' do
  sleep 0.24
  expect(true).to be true
end

it 'test case 2' do
  sleep 0.37
  expect(true).to be true
end

it 'test case 3' do
  sleep 0.47
  expect(true).to be true
end

it 'test case 4' do
  sleep 0.25
  expect(true).to be true
end

it 'test case 5' do
  sleep 0.33
  expect(true).to be true
end

it 'test case 6' do
  sleep 0.3408365156343807
  expect(true).to be true
end

end

# Total: ~2.0s
