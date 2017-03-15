module Slayer
  class Command
    attr_accessor :result

    # Internal: Command Class Methods
    class << self
      def call(*args, &block)
        execute_call(block, *args) { |c, *a| c.run(*a) }
      end

      private

      def execute_call(command_block, *args)
        # Run the Command and capture the result
        command = self.new
        result  = command.tap { yield(command, *args) }.result

        # Throw an exception if we don't return a result
        raise CommandNotImplementedError unless result.is_a? Result

        # Run the command block if one was provided
        unless command_block.nil?
          matcher = Slayer::ResultMatcher.new(result, command)

          command_block.call(matcher)

          # raise error if not all defaults were handled
          unless matcher.handled_defaults?
            raise(CommandResultNotHandledError, 'The pass or fail condition of a result was not handled')
          end

          begin
            matcher.execute_matching_block
          ensure
            matcher.execute_ensure_block
          end
        end

        return result
      end
    end # << self

    def run(*args)
      call(*args)
    rescue ResultFailureError
      # Swallow the Command Failure
    end

    # Create a passing Result
    def pass(value: nil, status: :default, message: nil)
      @result = Result.new(value, status, message)
    end

    # Create a failing Result
    def fail(value: nil, status: :default, message: nil)
      @result = Result.new(value, status, message).fail
    end

    # Create a failing Result and halt execution of the Command
    def fail!(value: nil, status: :default, message: nil)
      fail(value: value, status: status, message: message)
      raise ResultFailureError, self
    end

    # If the block produces a successful result the value of the result will be
    # returned. Otherwise, this will create a failing result and halt the execution
    # of the Command.
    def try!(value: nil, status: nil, message: nil)
      r = yield
      fail!(value: value, status: status || :default, message: message) unless r.kind_of?(Result)
      return r.value if r.success?
      fail!(value: value || r.value, status: status || r.status, message: message || r.message)
    end

    # Call the command
    def call
      raise NotImplementedError, 'Commands must define method `#call`.'
    end
  end
end
