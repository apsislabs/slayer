module Slayer
  class Result
    attr_reader :result, :message

    def initialize(result, message)
      @result = result
      @message = message
    end

    def clear_state
      @handled_pass = false
      @handled_fail = false
    end

    def fulfilled_state
      @handled_pass && @handled_fail
    end

    def pass(for_result = nil, &block)
      @handled_pass ||= for_result == nil || for_result == :default

      yield if (block_given? && success? && (for_result == nil || for_result == :default || for_result == @result))
    end

    def fail(for_result = nil, &block)
      @handled_fail ||= for_result == nil || for_result == :default

      yield if (block_given? && failure? && (for_result == nil || for_result == :default || for_result == @result))
    end

    def success?
      !failure?
    end

    def failure?
      @failure || false
    end

    def fail!
      @failure = true
      raise CommandFailure, self
    end
  end
end
