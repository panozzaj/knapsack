require_relative 'spec_helper'

RSpec.describe 'Very slow test 3' do
it 'test case 1' do
  sleep 0.27
  expect(true).to be true
end

it 'test case 2' do
  sleep 0.42
  expect(true).to be true
end

it 'test case 3' do
  sleep 0.55
  expect(true).to be true
end

it 'test case 4' do
  sleep 0.42
  expect(true).to be true
end

it 'test case 5' do
  sleep 0.47
  expect(true).to be true
end

it 'test case 6' do
  sleep 0.48
  expect(true).to be true
end

it 'test case 7' do
  sleep 0.3310061444772394
  expect(true).to be true
end

end

# Total: ~2.94s
