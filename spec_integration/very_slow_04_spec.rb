require_relative 'spec_helper'

RSpec.describe 'Very slow test 4' do
it 'test case 1' do
  sleep 0.38
  expect(true).to be true
end

it 'test case 2' do
  sleep 0.56
  expect(true).to be true
end

it 'test case 3' do
  sleep 0.31
  expect(true).to be true
end

it 'test case 4' do
  sleep 0.61
  expect(true).to be true
end

it 'test case 5' do
  sleep 0.45
  expect(true).to be true
end

it 'test case 6' do
  sleep 0.4175666124600795
  expect(true).to be true
end

end

# Total: ~2.73s
