module Slayer
  class ResultFailureError < Exception
    attr_reader :result

    def initialize(result)
      @result = result
      super "Slayer ResultFailureError: Error thrown to flunk #{result}. See https://github.com/apsislabs/slayer/wiki/Catching-the-ResultFailureError."
    end
  end

  # Base Slayer::Error
  class Error < StandardError; end

  class CommandNotImplementedError < Error
    def initialize(message = nil)
      message ||= 'Command implementation must return a <Slayer::Result> object'
      super message
    end
  end

  class ResultNotHandledError < Error; end
  class FormValidationError < Error; end
  class ServiceDependencyError < Error; end
end
