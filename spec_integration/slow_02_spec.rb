require_relative 'spec_helper'

RSpec.describe 'Slow test 2' do
it 'test case 1' do
  sleep 0.18
  expect(true).to be true
end

it 'test case 2' do
  sleep 0.12
  expect(true).to be true
end

it 'test case 3' do
  sleep 0.16
  expect(true).to be true
end

it 'test case 4' do
  sleep 0.15
  expect(true).to be true
end

it 'test case 5' do
  sleep 0.2
  expect(true).to be true
end

it 'test case 6' do
  sleep 0.30937612114379603
  expect(true).to be true
end

end

# Total: ~1.12s
