require_relative 'spec_helper'

RSpec.describe 'Medium test 11' do
it 'test case 1' do
  sleep 0.11
  expect(true).to be true
end

it 'test case 2' do
  sleep 0.19
  expect(true).to be true
end

it 'test case 3' do
  sleep 0.09
  expect(true).to be true
end

it 'test case 4' do
  sleep 0.16
  expect(true).to be true
end

it 'test case 5' do
  sleep 0.16672204682108063
  expect(true).to be true
end

end

# Total: ~0.72s
