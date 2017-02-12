module Slayer
  class Command
    attr_accessor :result

    # Internal: Command Class Methods
    class << self
      def call(*args, &block)
        execute_call(block, *args) { |c, *a| c.run(*a) }
      end

      def call!(*args, &block)
        execute_call(block, *args) { |c, *a| c.run!(*a) }
      end

      private

        def execute_call(block, *args, &lamda)
          # Run the Command and capture the result
          command = self.new
          result  = command.tap { lamda.call(command, *args) }.result

          # Throw an exception if we don't return a result
          raise CommandNotImplemented unless result.is_a? Result

          # Run user block
          result.clear_state
          block.call(result, command) unless block.nil?
          raise CommandResultNotHandledError.new("The pass or fail condition of a result was not handled") unless result.fulfilled_state

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

    # Call the command
    def call
      raise NotImplementedError, "Commands must define method `#call`."
    end
  end
end
