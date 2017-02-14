$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'simplecov'
require 'coveralls'

SimpleCov.formatters = [
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]

SimpleCov.start do
  add_filter '/test/'
  minimum_coverage(95)
end

require 'slayer'
require 'byebug'
require 'minitest/autorun'
require 'minitest/mock'
require 'minitest/reporters'
require 'mocha/mini_test'

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

Dir['test/assertions/**/*.rb'].each { |f| require File.expand_path(f) }
Dir['test/fixtures/**/*.rb'].each { |f| require File.expand_path(f) }
