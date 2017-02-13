module Slayer
  class CommandFailureError < StandardError
    attr_reader :result

    def initialize(result)
      @result = result
      super
    end
  end

  class CommandNotImplementedError < StandardError
    def initialize(message = nil)
      message ||= %q(
        Command implementation must call `fail!` or `pass!`,
        or return a <Slayer::Result> object
      )

      super message
    end
  end

  class ServiceDependencyError < StandardError; end
end
