require_relative 'spec_helper'

RSpec.describe 'Fast test 7' do
it 'test case 1' do
  sleep 0.1
  expect(true).to be true
end

it 'test case 2' do
  sleep 0.07
  expect(true).to be true
end

it 'test case 3' do
  sleep 0.09253307804998248
  expect(true).to be true
end

end

# Total: ~0.26s
