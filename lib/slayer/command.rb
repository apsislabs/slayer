module Slayer
  class Command
    attr_accessor :result

    # Internal: Command Class Methods
    class << self
      def call(*args, &block)
        # Run the Command and capture the result
        result = new.tap { |s|
          s.run(*args, &block)
        }.result

        # Throw an exception if we don't return a result
        raise CommandNotImplemented unless result.is_a? Result
        return result
      end
    end

    # Run the Command, rescue from Failures
    def run(*args, &block)
      begin
        run!(*args, &block)
      rescue CommandFailure
      end
    end

    # Run the Command
    def run!(*args, &block)
      call(*args, &block)
    end

    # Fail the Command
    def fail!(result:, message:)
      @result = Result.new(result, message)
      @result.fail!
    end

    # Pass the Command
    def pass!(result:, message:)
      @result = Result.new(result, message)
    end

    # Call the service
    def call
      raise NotImplementedError, "Commands must define method `#call`."
    end
  end
end
