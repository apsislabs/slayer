module Slayer
  class Command
    attr_accessor :result

    # Internal: Command Class Methods
    class << self
      def call(*args, &block)
        # Run the Command and capture the result
        command = self.new
        result  = command.tap { |s| s.run(*args) }.result

        # Run block
        yield(result, command) if block_given?

        # Throw an exception if we don't return a result
        raise CommandNotImplemented unless result.is_a? Result
        return result
      end

      def call!(*args, &block)
        # Run the Command and capture the result
        command = self.new
        result  = command.tap { |s| s.run!(*args) }.result

        # Run block
        yield(result, command) if block_given?

        # Throw an exception if we don't return a result
        raise CommandNotImplemented unless result.is_a? Result
        return result
      end
    end

    def run(*args)
      begin
        call(*args)
      rescue CommandFailure
      end
    end

    # Run the Command
    def run!(*args)
      call(*args)
    end

    # Fail the Command
    def fail!(result:, message: nil)
      @result = Result.new(result, message)
      @result.fail!
    end

    # Pass the Command
    def pass!(result:, message: nil)
      @result = Result.new(result, message)
    end

    # Call the service
    def call
      raise NotImplementedError, "Commands must define method `#call`."
    end
  end
end
