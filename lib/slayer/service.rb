module Slayer
  class Service
    include Hook

    skip_hooking :pass!, :fail!, :try!

    def self.pass!(value: nil, status: :default, message: nil)
      Fiber.yield Result.new(value, status, message)
    end

    def self.fail!(value: nil, status: :default, message: nil)
      r = Result.new(value, status, message)
      r.fail
      Fiber.yield r
    end

    def self.try!(value: nil, status: nil, message: nil)
      r = yield

      if r.failure?
        fail!(value: value || r.value, status: status || r.status, message: message || r.message)
      end

      r.value
    end

    def pass!(*args)
      self.class.pass!(*args)
    end

    def fail!(*args)
      self.class.fail!(*args)
    end

    def try!(*args, &block)
      self.class.try!(*args, &block)
    end

    private

    def self.inherited(klass)
      klass.include Hook
      klass.hook :result_machinery
    end

    hook :result_machinery

    def self.result_machinery(name, service_block)
      service_fiber = Fiber.new do
        yield
      end
      result = service_fiber.resume

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
