# :nocov:

module Slayer
  class Command
    class << self
      def pass(value: nil, status: :default, message: nil)
        warn '[DEPRECATION] `pass` is deprecated.  Please use `ok` instead.' unless ENV['SUPPRESS_SLAYER_WARNINGS']
        ok(value: value, status: status, message: message)
      end

      def flunk(value: nil, status: :default, message: nil)
        warn '[DEPRECATION] `flunk` is deprecated.  Please use `err` instead.' unless ENV['SUPPRESS_SLAYER_WARNINGS']
        err(value: value, status: status, message: message)
      end

      def flunk!(value: nil, status: :default, message: nil)
        unless ENV['SUPPRESS_SLAYER_WARNINGS']
          warn '[DEPRECATION] `flunk!` is deprecated.  Please use `return err` instead.'
        end
        err!(value: value, status: status, message: message)
      end
    end

    alias pass ok
    alias flunk err
    alias flunk! err!
  end

  class Result
    def success?
      warn '[DEPRECATION] `success?` is deprecated.  Please use `ok?` instead.' unless ENV['SUPPRESS_SLAYER_WARNINGS']
      ok?
    end

    def failure?
      warn '[DEPRECATION] `failure?` is deprecated.  Please use `err?` instead.' unless ENV['SUPPRESS_SLAYER_WARNINGS']
      err?
    end
  end

  class ResultMatcher
    def pass(...)
      warn '[DEPRECATION] `pass` is deprecated.  Please use `ok` instead.' unless ENV['SUPPRESS_SLAYER_WARNINGS']
      ok(...)
    end

    def fail(...)
      warn '[DEPRECATION] `fail` is deprecated.  Please use `err` instead.' unless ENV['SUPPRESS_SLAYER_WARNINGS']
      err(...)
    end
  end
end

# :nocov:
