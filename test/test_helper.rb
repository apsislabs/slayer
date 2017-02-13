$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'slayer'
require 'byebug'
require 'minitest/autorun'
require 'minitest/mock'
require 'minitest/reporters'
require 'mocha/mini_test'

Dir["test/fixtures/**/*.rb"].each { |f| require File.expand_path(f) }

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

# Added assertions

def assert_executes(exactly: nil, at_least: nil, message: "The given block did not execute the desired statement")
  @assert_executes_stack ||= []
  @assert_executes_stack << 0

  yield

  at_least = 1 if (!exactly && !at_least)

  assert @assert_executes_stack.pop == exactly, message  if exactly
  assert @assert_executes_stack.pop >= at_least, message if at_least
end

def assert_not_executes(exactly: nil, at_least: nil, message: "The given block executed the statement it should not have executed")
  @assert_executes_stack ||= []
  @assert_executes_stack << 0

  yield

  at_least = 1 if (!exactly && !at_least)

  refute @assert_executes_stack.pop == exactly, message  if exactly
  refute @assert_executes_stack.pop >= at_least, message if at_least
end

alias refute_executes assert_not_executes
alias refute_not_executes assert_executes # please nobody ever use this.

def executes
  @assert_executes_stack[-1] = @assert_executes_stack[-1]+1
end
