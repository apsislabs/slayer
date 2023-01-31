module Slayer
  class Result
    attr_reader :value, :status, :message

    def initialize(value, status, message)
      @value   = value
      @status  = status
      @message = message
    end

    def ok?
      !err?
    end

    def err?
      @err ||= false
    end

    def fail
      @err ||= true
      self
    end
  end
end
