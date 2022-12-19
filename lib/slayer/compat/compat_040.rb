# :nocov:
require 'minitest/assertions'
require 'rspec/expectations'

module Slayer
  class Command
    class << self
      def pass(value: nil, status: :default, message: nil)
        warn '[DEPRECATION] `pass` is deprecated.  Please use `ok` instead.'
        ok(value: value, status: status, message: message)
      end


      def flunk(value: nil, status: :default, message: nil)
        warn '[DEPRECATION] `flunk` is deprecated.  Please use `err` instead.'
        err(value: value, status: status, message: message)
      end

      def flunk!(value: nil, status: :default, message: nil)
        warn '[DEPRECATION] `flunk!` is deprecated.  Please use `return err` instead.'
        err!(value: value, status: status, message: message)
      end
    end

    alias pass ok
    alias flunk err
    alias flunk! err!
  end

  class Result
    def success?
      warn '[DEPRECATION] `success?` is deprecated.  Please use `ok?` instead.'
      ok?
    end

    def failure?
      warn '[DEPRECATION] `failure?` is deprecated.  Please use `err?` instead.'
      err?
    end
  end

  class ResultMatcher
    def pass(...)
      warn '[DEPRECATION] `pass` is deprecated.  Please use `ok` instead.'
      ok(...)
    end

    def fail(...)
      warn '[DEPRECATION] `fail` is deprecated.  Please use `err` instead.'
      err(...)
    end
  end
end

module Minitest::Assertions
  alias assert_success assert_ok
  alias refute_failed assert_ok
  alias assert_failed refute_ok
  alias refute_success refute_ok
end

RSpec::Matchers.alias_matcher :be_failed_result, :be_err_result
RSpec::Matchers.alias_matcher :be_success_result, :be_ok_result

# :nocov:
