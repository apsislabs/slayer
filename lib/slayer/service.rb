module Slayer
  # Slayer Services are objects that should implement re-usable pieces of
  # application logic or common tasks. All methods in a service are wrapped
  # by default to enforce the return of a +Slayer::Result+ object.
  class Service
    include Hook

    skip_hook :pass, :flunk, :flunk!, :try!, :opt_in?, :__opt_in
    singleton_skip_hook :pass, :flunk, :flunk!, :try!, :opt_in?, :opt_in!, :__opt_in

    attr_accessor :result

    class << self
      # Create a passing Result
      def pass(value: nil, status: :default, message: nil)
        Result.new(value, status, message)
      end

      # Create a failing Result
      def flunk(value: nil, status: :default, message: nil)
        Result.new(value, status, message).fail
      end

      # Create a failing Result and halt execution of the Command
      def flunk!(value: nil, status: :default, message: nil)
        raise ResultFailureError, flunk(value: value, status: status, message: message)
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

      def opt_in!
        @__opt_in
      end

      def opt_in?
        __opt_in
      end

      private

        def __opt_in
          __opt_in = true if __opt_in == nil
          __opt_in
        end
    end

    def pass(*args)
      self.class.pass(*args)
    end

    def flunk(*args)
      self.class.flunk(*args)
    end

    def flunk!(*args)
      self.class.flunk!(*args)
    end

    def try!(*args, &block)
      self.class.try!(*args, &block)
    end

    def opt_in?
      self.class.opt_in?
    end

    # Make sure child classes also hook correctly
    def self.inherited(klass)
      klass.include Hook
      klass.hook :__service_hook
    end

    hook :__service_hook

    # rubocop:disable Metrics/MethodLength
    def self.__service_hook(_, instance, service_block)
      return yield unless opt_in?

      begin
        result = yield
      rescue ResultFailureError => error
        result = error.result
      end

      raise CommandNotImplementedError unless result.is_a? Result

      unless service_block.nil?
        matcher = Slayer::ResultMatcher.new(result, instance)

        service_block.call(matcher)

        # raise error if not all defaults were handled
        unless matcher.handled_defaults?
          raise(ResultNotHandledError, 'The pass or fail condition of a result was not handled')
        end

        begin
          matcher.execute_matching_block
        ensure
          matcher.execute_ensure_block
        end
      end
      return result
    end
    # rubocop:enable Metrics/MethodLength

    private_class_method :inherited
    private_class_method :__service_hook

  end # class Service
end # module Slayer
