module Slayer
  class Command < Service
    singleton_skip_hook :call

    class << self
      def method_added(name)
        return unless name == :call
        super(name)
      end

      def call(*args, &block)
        self.new.call(*args, &block)
      end
    end

    def call
      raise NotImplementedError, 'Commands must define method `#call`.'
    end
  end
end