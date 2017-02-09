module Slayer
  class CommandFailure < StandardError
    attr_reader :result

    def initialize(result)
      @result = result
      super
    end
  end

  class CommandNotImplemented < StandardError
    def initialize(message = nil)
      message ||= %q(
        Command implementation must call `fail!` or `pass!`,
        or return a <Slayer::Result> object
      )

      super message
    end
  end
end
