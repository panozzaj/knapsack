require_relative 'spec_helper'

RSpec.describe 'Medium test 4' do
it 'test case 1' do
  sleep 0.1
  expect(true).to be true
end

it 'test case 2' do
  sleep 0.11
  expect(true).to be true
end

it 'test case 3' do
  sleep 0.1
  expect(true).to be true
end

it 'test case 4' do
  sleep 0.10779642250041019
  expect(true).to be true
end

end

# Total: ~0.42s
