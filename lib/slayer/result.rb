module Slayer
  class Result
    attr_reader :value, :status, :message

    def initialize(value, status, message)
      @value   = value
      @status  = status
      @message = message
    end

    def passed?
      !failed?
    end
    alias success? passed?

    def failed?
      @failed ||= false
    end
    alias failure? failed?

    def fail
      @failed ||= true
      self
    end
  end
end
