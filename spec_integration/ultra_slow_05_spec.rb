require_relative 'spec_helper'

RSpec.describe 'Ultra slow test 5' do
it 'test case 1' do
  sleep 0.25
  expect(true).to be true
end

it 'test case 2' do
  sleep 0.32
  expect(true).to be true
end

it 'test case 3' do
  sleep 0.28
  expect(true).to be true
end

it 'test case 4' do
  sleep 0.37
  expect(true).to be true
end

it 'test case 5' do
  sleep 0.36
  expect(true).to be true
end

it 'test case 6' do
  sleep 0.4
  expect(true).to be true
end

it 'test case 7' do
  sleep 0.21
  expect(true).to be true
end

it 'test case 8' do
  sleep 0.39
  expect(true).to be true
end

it 'test case 9' do
  sleep 0.35
  expect(true).to be true
end

it 'test case 10' do
  sleep 0.3251359306937005
  expect(true).to be true
end

end

# Total: ~3.26s
