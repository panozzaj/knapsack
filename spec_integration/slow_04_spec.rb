require_relative 'spec_helper'

RSpec.describe 'Slow test 4' do
it 'test case 1' do
  sleep 0.14
  expect(true).to be true
end

it 'test case 2' do
  sleep 0.18
  expect(true).to be true
end

it 'test case 3' do
  sleep 0.17
  expect(true).to be true
end

it 'test case 4' do
  sleep 0.25
  expect(true).to be true
end

it 'test case 5' do
  sleep 0.16
  expect(true).to be true
end

it 'test case 6' do
  sleep 0.23
  expect(true).to be true
end

it 'test case 7' do
  sleep 0.2043901037433737
  expect(true).to be true
end

end

# Total: ~1.33s
