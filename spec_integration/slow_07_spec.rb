require_relative 'spec_helper'

RSpec.describe 'Slow test 7' do
it 'test case 1' do
  sleep 0.15
  expect(true).to be true
end

it 'test case 2' do
  sleep 0.09
  expect(true).to be true
end

it 'test case 3' do
  sleep 0.12
  expect(true).to be true
end

it 'test case 4' do
  sleep 0.13
  expect(true).to be true
end

it 'test case 5' do
  sleep 0.07
  expect(true).to be true
end

it 'test case 6' do
  sleep 0.09
  expect(true).to be true
end

it 'test case 7' do
  sleep 0.14
  expect(true).to be true
end

it 'test case 8' do
  sleep 0.1669194365568517
  expect(true).to be true
end

end

# Total: ~0.96s
