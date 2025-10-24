require_relative 'spec_helper'

RSpec.describe 'Fast test 4' do
it 'test case 1' do
  sleep 0.03
  expect(true).to be true
end

it 'test case 2' do
  sleep 0.04
  expect(true).to be true
end

it 'test case 3' do
  sleep 0.04
  expect(true).to be true
end

it 'test case 4' do
  sleep 0.02890927526596391
  expect(true).to be true
end

end

# Total: ~0.14s
