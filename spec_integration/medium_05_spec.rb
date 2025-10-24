require_relative 'spec_helper'

RSpec.describe 'Medium test 5' do
it 'test case 1' do
  sleep 0.08
  expect(true).to be true
end

it 'test case 2' do
  sleep 0.07
  expect(true).to be true
end

it 'test case 3' do
  sleep 0.09
  expect(true).to be true
end

it 'test case 4' do
  sleep 0.13
  expect(true).to be true
end

it 'test case 5' do
  sleep 0.06232418608297166
  expect(true).to be true
end

end

# Total: ~0.43s
