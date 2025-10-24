require_relative 'spec_helper'

RSpec.describe 'Ultra slow test 4' do
it 'test case 1' do
  sleep 0.3
  expect(true).to be true
end

it 'test case 2' do
  sleep 0.31
  expect(true).to be true
end

it 'test case 3' do
  sleep 0.3
  expect(true).to be true
end

it 'test case 4' do
  sleep 0.47
  expect(true).to be true
end

it 'test case 5' do
  sleep 0.58
  expect(true).to be true
end

it 'test case 6' do
  sleep 0.32
  expect(true).to be true
end

it 'test case 7' do
  sleep 0.43
  expect(true).to be true
end

it 'test case 8' do
  sleep 0.5
  expect(true).to be true
end

it 'test case 9' do
  sleep 0.37
  expect(true).to be true
end

it 'test case 10' do
  sleep 0.7155630488475445
  expect(true).to be true
end

end

# Total: ~4.3s
