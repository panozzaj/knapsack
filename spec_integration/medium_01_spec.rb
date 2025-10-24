require_relative 'spec_helper'

RSpec.describe 'Medium test 1' do
it 'test case 1' do
  sleep 0.1
  expect(true).to be true
end

it 'test case 2' do
  sleep 0.08
  expect(true).to be true
end

it 'test case 3' do
  sleep 0.08
  expect(true).to be true
end

it 'test case 4' do
  sleep 0.07
  expect(true).to be true
end

it 'test case 5' do
  sleep 0.09165178975292726
  expect(true).to be true
end

end

# Total: ~0.42s
