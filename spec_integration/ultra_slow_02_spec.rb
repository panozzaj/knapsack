require_relative 'spec_helper'

RSpec.describe 'Ultra slow test 2' do
it 'test case 1' do
  sleep 0.4
  expect(true).to be true
end

it 'test case 2' do
  sleep 0.31
  expect(true).to be true
end

it 'test case 3' do
  sleep 0.4
  expect(true).to be true
end

it 'test case 4' do
  sleep 0.39
  expect(true).to be true
end

it 'test case 5' do
  sleep 0.3
  expect(true).to be true
end

it 'test case 6' do
  sleep 0.37
  expect(true).to be true
end

it 'test case 7' do
  sleep 0.35
  expect(true).to be true
end

it 'test case 8' do
  sleep 0.18
  expect(true).to be true
end

it 'test case 9' do
  sleep 0.34
  expect(true).to be true
end

it 'test case 10' do
  sleep 0.21
  expect(true).to be true
end

it 'test case 11' do
  sleep 0.16
  expect(true).to be true
end

it 'test case 12' do
  sleep 0.310035737725055
  expect(true).to be true
end

end

# Total: ~3.72s
