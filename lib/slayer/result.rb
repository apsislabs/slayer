module Slayer
  class Result
    # TODO: Result needs another attribute like "status" for full block matching.
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

    def pass(for_status = nil, &block)
      @handled_pass ||= for_status == nil || for_status == :default

      yield if (block_given? && success? && (for_status == nil || for_status == :default || for_status == @result))
    end

    def fail(for_status = nil, &block)
      @handled_fail ||= for_status == nil || for_status == :default

      yield if (block_given? && failure? && (for_status == nil || for_status == :default || for_status == @result))
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
