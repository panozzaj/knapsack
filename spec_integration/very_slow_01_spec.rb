require_relative 'spec_helper'

RSpec.describe 'Very slow test 1' do
it 'test case 1' do
  sleep 0.28
  expect(true).to be true
end

it 'test case 2' do
  sleep 0.32
  expect(true).to be true
end

it 'test case 3' do
  sleep 0.46
  expect(true).to be true
end

it 'test case 4' do
  sleep 0.39
  expect(true).to be true
end

it 'test case 5' do
  sleep 0.23
  expect(true).to be true
end

it 'test case 6' do
  sleep 0.364396260548996
  expect(true).to be true
end

end

# Total: ~2.04s
