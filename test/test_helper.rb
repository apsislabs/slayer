$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'slayer'
require 'byebug'
require 'minitest/autorun'
require 'minitest/mock'
require 'minitest/reporters'
require 'mocha/mini_test'
require 'coveralls'

Coveralls.wear!

Dir['test/fixtures/**/*.rb'].each { |f| require File.expand_path(f) }
Dir['test/assertions/**/*.rb'].each { |f| require File.expand_path(f) }

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new
