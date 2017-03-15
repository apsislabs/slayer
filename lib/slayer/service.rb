module Slayer
  # A service is intended to be business logic that can be shared and reused by
  # a number of commands.
  #
  # Service methods produce a result and have the same `pass!`, `fail!` and `try!`
  # mechanisms that are available to Commands.
  class Service
    include Hook

    skip_hook :pass, :flunk, :flunk!, :try!

    # TODO: Unify this code with the Result method calls in command.
    def self.pass(value: nil, status: :default, message: nil)
      Result.new(value, status, message)
    end

    def self.flunk(value: nil, status: :default, message: nil)
      Result.new(value, status, message).fail
    end

    def self.flunk!(value: nil, status: :default, message: nil)
      result = Result.new(value, status, message).fail
      raise ResultFailureError, result
    end

    def self.try!(value: nil, status: nil, message: nil)
      r = yield
      flunk!(value: value, status: status || :default, message: message) unless r.is_a?(Result)
      return r.value if r.success?
      flunk!(value: value || r.value, status: status || r.status, message: message || r.message)
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

    private

    def self.inherited(klass)
      klass.include Hook
      klass.hook :__service_hook
    end

    hook :__service_hook

    def self.__service_hook(name, service_block)

      result = nil
      begin
        result = yield
      rescue ResultFailureError => error
        result = error.result
      end

      unless service_block.nil?
        matcher = Slayer::ResultMatcher.new(result, nil)

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
  end # class Service
end # module Slayer
