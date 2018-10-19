module Slayer
  class Command < Service
    singleton_skip_hook :call

    class << self
      def call(*args, &block)
        self.new.call(*args, &block)
      end

      private

      def inherited(klass)
        super(klass)
        klass.wrap_service_methods!
        klass.only_hook :call
      end
    end

    def call
      raise NotImplementedError, 'Commands must define method `#call`.'
    end
  end
end
