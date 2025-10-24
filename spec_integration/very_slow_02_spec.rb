require_relative 'spec_helper'

RSpec.describe 'Very slow test 2' do
it 'test case 1' do
  sleep 0.29
  expect(true).to be true
end

it 'test case 2' do
  sleep 0.37
  expect(true).to be true
end

it 'test case 3' do
  sleep 0.2
  expect(true).to be true
end

it 'test case 4' do
  sleep 0.16
  expect(true).to be true
end

it 'test case 5' do
  sleep 0.34
  expect(true).to be true
end

it 'test case 6' do
  sleep 0.19
  expect(true).to be true
end

it 'test case 7' do
  sleep 0.3806806053982143
  expect(true).to be true
end

end

# Total: ~1.93s
