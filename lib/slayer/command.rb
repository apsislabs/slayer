module Slayer
  class Command
    class << self
      def call(*args, **kwargs, &block)
        instance = new

        res = __get_result(instance, *args, **kwargs, &block)
        handle_match(res, instance, block) if block_given?

        raise CommandNotImplementedError unless res.is_a? Result

        res
      end

      def ok(value: nil, status: :default, message: nil)
        Result.new(value, status, message)
      end

      def err(value: nil, status: :default, message: nil)
        ok(value: value, status: status, message: message).fail
      end

      def err!(value: nil, status: :default, message: nil)
        unless ENV["SUPPRESS_SLAYER_WARNINGS"]
          warn "[DEPRECATION] `err!` is deprecated.  Please use `return err` instead."
        end
        raise ResultFailureError, err(value: value, status: status, message: message)
      end

      def __get_result(instance, ...)
        res = nil

        begin
          res = instance.call(...)
        rescue ResultFailureError => e
          res = e.result
        end

        res
      end

      private

      def handle_match(res, instance, block)
        matcher = Slayer::ResultMatcher.new(res, instance)

        block.call(matcher)

        # raise error if not all defaults were handled
        unless matcher.handled_defaults?
          raise(ResultNotHandledError, "The pass or fail condition of a result was not handled")
        end

        begin
          matcher.execute_matching_block
        ensure
          matcher.execute_ensure_block
        end
      end
    end

    def ok(...)
      self.class.ok(...)
    end

    def err(...)
      self.class.err(...)
    end

    def err!(...)
      self.class.err!(...)
    end

    def try!(value: nil, status: nil, message: nil)
      r = yield
      err!(value: value, status: status || :default, message: message) unless r.is_a?(Result)
      return r.value if r.ok?

      err!(value: value || r.value, status: status || r.status, message: message || r.message)
    end

    def call
      raise NotImplementedError, "Commands must define method `#call`."
    end
  end
end
