module Slayer
  class ResultFailureError < StandardError
    attr_reader :result

    def initialize(result)
      @result = result
      super "Slayer ResultFailureError: Error thrown to flunk #{result}. See https://github.com/apsislabs/slayer/wiki/Catching-the-ResultFailureError."
    end
  end

  class CommandNotImplementedError < StandardError
    def initialize(message = nil)
      message ||= 'Command implementation must return a <Slayer::Result> object'
      super message
    end
  end

  class ResultNotHandledError < StandardError; end
  class FormValidationError < StandardError; end
  class ServiceDependencyError < StandardError; end
end
