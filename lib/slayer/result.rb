module Slayer
  class Result
    attr_reader :value, :status, :message

    def initialize(value, status, message)
      @value   = value
      @status  = status
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
      raise CommandFailureErrorError, self
    end
  end
end
