require_relative 'spec_helper'

RSpec.describe 'Fast test 6' do
it 'test case 1' do
  sleep 0.03
  expect(true).to be true
end

it 'test case 2' do
  sleep 0.03
  expect(true).to be true
end

it 'test case 3' do
  sleep 0.05
  expect(true).to be true
end

it 'test case 4' do
  sleep 0.03
  expect(true).to be true
end

it 'test case 5' do
  sleep 0.032091230532976536
  expect(true).to be true
end

end

# Total: ~0.17s
