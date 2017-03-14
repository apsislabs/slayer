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

      def execute_call(command_block, *args)
        # Run the Command and capture the result
        command = self.new
        command_fiber = Fiber.new do
          puts "Starting Command Fiber"

          r = command.tap { yield(command, *args) }.result

          puts "Command fiber ran to completion: #{r.inspect}"

          r
        end
        result = command_fiber.resume


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
    end

    # Run the Command
    def run!(*args)
      call(*args)
    end

    # Fail the Command

    def fail!(value: nil, status: :default, message: nil)
      @result = Result.new(value, status, message)
      @result.fail
      Fiber.yield @result

    end

    # Pass the Command
    def pass!(value: nil, status: :default, message: nil)
      @result = Result.new(value, status, message)
      Fiber.yield @result
    end

    # Call the command
    def call
      raise NotImplementedError, 'Commands must define method `#call`.'
    end
  end
end
