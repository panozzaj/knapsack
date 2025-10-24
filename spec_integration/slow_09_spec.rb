require_relative 'spec_helper'

RSpec.describe 'Slow test 9' do
it 'test case 1' do
  sleep 0.19
  expect(true).to be true
end

it 'test case 2' do
  sleep 0.21
  expect(true).to be true
end

it 'test case 3' do
  sleep 0.25
  expect(true).to be true
end

it 'test case 4' do
  sleep 0.2
  expect(true).to be true
end

it 'test case 5' do
  sleep 0.14791327567775941
  expect(true).to be true
end

end

# Total: ~1.0s
