require_relative 'spec_helper'

RSpec.describe 'Fast test 10' do
it 'test case 1' do
  sleep 0.05
  expect(true).to be true
end

it 'test case 2' do
  sleep 0.06
  expect(true).to be true
end

it 'test case 3' do
  sleep 0.07
  expect(true).to be true
end

it 'test case 4' do
  sleep 0.10074497342973793
  expect(true).to be true
end

end

# Total: ~0.28s
