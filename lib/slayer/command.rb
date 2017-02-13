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
          raise CommandNotImplementedError unless result.is_a? Result

          # Run user block
          unless block.nil?
            matcher = Slayer::ResultMatcher.new(result, command)

            block.call(matcher)

            # raise error if not all defaults were handled
            if !matcher.handled_defaults?
              raise CommandResultNotHandledError.new("The pass or fail condition of a result was not handled")
            end

            matcher.execute_matching_block
          end

          return result
        end
    end

    def run(*args)
      begin
        call(*args)
      rescue CommandFailureError
      end
    end

    # Run the Command
    def run!(*args)
      call(*args)
    end

    # Fail the Command
    def fail!(result:, status: :default, message: nil)
      @result = Result.new(result, status, message)
      @result.fail!
    end

    # Pass the Command
    def pass!(result:, status: :default, message: nil)
      @result = Result.new(result, status, message)
    end

    # Call the command
    def call
      raise NotImplementedError, "Commands must define method `#call`."
    end
  end
end
