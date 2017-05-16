module Slayer
  class Service
    attr_accessor :result

    class << self
      def method_added(name)
        super(name)

        # Bail early for conditions we don't want to wrap
        return if private_instance_methods.include? name
        return if private_methods.include? name
        return if [:pass, :flunk, :flunk!, :try!].include? name
        return if @__last_methods_added && @__last_methods_added.include?(name)

        run_method = :"__run_#{name}"
        @__last_methods_added = [name, run_method]

        puts "Define methods for #{name}, #{run_method} on #{self}"

        # Define method for running instance method in a wrapped
        # way.
        define_method run_method do |*args|
          begin
            send(name, *args)
          rescue ResultFailureError
          end
        end

        # Define wrapper method for calling on class
        define_singleton_method name do |*args, &block|
          self.__execute(block, *args) { |c, *a| c.send("__run_#{name}", *a) }
        end

        @__last_methods_added = nil
      end

      def __execute(block, *args)
        # Run the service and capture the result
        service = self.new
        result  = service.tap { yield(service, *args) }.result

        # Throw an exception if we don't return a result
        raise CommandNotImplementedError unless result.is_a? Result

        # Run the service block if one was provided
        unless block.nil?
          matcher = Slayer::ResultMatcher.new(result, service)

          block.call(matcher)

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

    # Create a passing Result
    def pass(value: nil, status: :default, message: nil)
      @result = Result.new(value, status, message)
    end

    # Create a failing Result
    def flunk(value: nil, status: :default, message: nil)
      @result = Result.new(value, status, message).fail
    end

    # Create a failing Result and halt execution of the Command
    def flunk!(value: nil, status: :default, message: nil)
      flunk(value: value, status: status, message: message)
      raise ResultFailureError, self
    end

    # If the block produces a successful result the value of the result will be
    # returned. Otherwise, this will create a failing result and halt the execution
    # of the Command.
    def try!(value: nil, status: nil, message: nil)
      r = yield
      flunk!(value: value, status: status || :default, message: message) unless r.is_a?(Result)
      return r.value if r.success?
      flunk!(value: value || r.value, status: status || r.status, message: message || r.message)
    end

  end # class Service
end # module Slayer
