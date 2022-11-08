module Slayer
  class Command
    class << self
      def call(*args, &block)
        instance = self.new

        begin
          res = instance.call(*args, &block)
        rescue ResultFailureError => e
          res = e.result
        end

        raise CommandNotImplementedError unless res.is_a? Result

        handle_match(res, instance, block) if block_given?
        return res
      end
      ruby2_keywords :call if respond_to?(:ruby2_keywords, true)

      def ok(value: nil, status: :default, message: nil)
        Result.new(value, status, message)
      end
      alias pass ok

      def ko(value: nil, status: :default, message: nil)
        ok(value:, status:, message:).fail
      end
      alias flunk ko

      def ko!(value: nil, status: :default, message: nil)
        raise ResultFailureError, ko(value:, status:, message:)
      end
      alias flunk! ko!

      private

      def handle_match(res, instance, block)
        matcher = Slayer::ResultMatcher.new(res, instance)

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
      ko!(value:, status: status || :default, message:) unless r.is_a?(Result)
      return r.value if r.success?

      ko!(value: value || r.value, status: status || r.status, message: message || r.message)
    end

    def call
      raise NotImplementedError, 'Commands must define method `#call`.'
    end
  end
end
