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

    def success?
      warn '[DEPRECATION] `success?` is deprecated.  Please use `ok?` instead.'
      ok?
    end

    def err?
      @err ||= false
    end

    def failure?
      warn '[DEPRECATION] `failure?` is deprecated.  Please use `err?` instead.'
      err?
    end

    def fail
      @err ||= true
      self
    end
  end
end
