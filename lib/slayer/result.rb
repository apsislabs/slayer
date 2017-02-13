module Slayer
  class Result
    attr_reader :result, :message

    def initialize(result, message)
      @result = result
      @message = message
    end

    def success?
      !failure?
    end

    def failure?
      @failure || false
    end

    def fail!
      @failure = true
      raise CommandFailureError, self
    end
  end
end
