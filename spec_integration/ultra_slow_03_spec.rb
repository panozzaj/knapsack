require_relative 'spec_helper'

RSpec.describe 'Ultra slow test 3' do
it 'test case 1' do
  sleep 0.31
  expect(true).to be true
end

it 'test case 2' do
  sleep 0.31
  expect(true).to be true
end

it 'test case 3' do
  sleep 0.35
  expect(true).to be true
end

it 'test case 4' do
  sleep 0.23
  expect(true).to be true
end

it 'test case 5' do
  sleep 0.38
  expect(true).to be true
end

it 'test case 6' do
  sleep 0.32
  expect(true).to be true
end

it 'test case 7' do
  sleep 0.23
  expect(true).to be true
end

it 'test case 8' do
  sleep 0.23
  expect(true).to be true
end

it 'test case 9' do
  sleep 0.33
  expect(true).to be true
end

it 'test case 10' do
  sleep 0.37
  expect(true).to be true
end

it 'test case 11' do
  sleep 0.22
  expect(true).to be true
end

it 'test case 12' do
  sleep 0.289859278348093
  expect(true).to be true
end

end

# Total: ~3.57s
