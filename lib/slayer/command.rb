module Slayer
  class Command
    class << self
      def call(*args, &block)
        begin
          res = self.new.call(*args, &block)
        rescue ResultFailureError => error
          res = error.result
        end

        raise CommandNotImplementedError unless res.is_a? Result

        if block_given?
          matcher = Slayer::ResultMatcher.new(res, self.new)

          block.call(matcher)

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

        return res
      end
      ruby2_keywords :call if respond_to?(:ruby2_keywords, true)

      def ok(value: nil, status: :default, message: nil)
        Result.new(value, status, message)
      end
      alias pass ok

      def ko(value: nil, status: :default, message: nil)
        ok(value: value, status: status, message: message).fail
      end
      alias flunk ko

      def ko!(value: nil, status: :default, message: nil)
        raise ResultFailureError, ko(value: value, status: status, message: message)
      end
      alias flunk! ko!
    end

    def ok(*args)
      self.class.ok(*args)
    end
    alias pass ok
    ruby2_keywords :ok if respond_to?(:ruby2_keywords, true)

    def ko(*args)
      self.class.ko(*args)
    end
    alias flunk ko
    ruby2_keywords :ko if respond_to?(:ruby2_keywords, true)

    def ko!(*args)
      self.class.ko!(*args)
    end
    alias flunk! ko!
    ruby2_keywords :ko! if respond_to?(:ruby2_keywords, true)

    def try!(value: nil, status: nil, message: nil)
      r = yield
      ko!(value: value, status: status || :default, message: message) unless r.is_a?(Result)
      return r.value if r.success?
      ko!(value: value || r.value, status: status || r.status, message: message || r.message)
    end

    def call
      raise NotImplementedError, 'Commands must define method `#call`.'
    end
  end
end
