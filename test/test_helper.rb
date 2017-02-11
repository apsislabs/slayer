$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'slayer'
require 'minitest/autorun'
require 'minitest/mock'
require 'mocha/mini_test'

Dir["test/fixtures/**/*.rb"].each { |f| require File.expand_path(f) }
