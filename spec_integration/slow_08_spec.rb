require_relative 'spec_helper'

RSpec.describe 'Slow test 8' do
it 'test case 1' do
  sleep 0.17
  expect(true).to be true
end

it 'test case 2' do
  sleep 0.22
  expect(true).to be true
end

it 'test case 3' do
  sleep 0.19
  expect(true).to be true
end

it 'test case 4' do
  sleep 0.22
  expect(true).to be true
end

it 'test case 5' do
  sleep 0.13
  expect(true).to be true
end

it 'test case 6' do
  sleep 0.27
  expect(true).to be true
end

it 'test case 7' do
  sleep 0.1349676123355067
  expect(true).to be true
end

end

# Total: ~1.33s
