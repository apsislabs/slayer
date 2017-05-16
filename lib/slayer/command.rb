module Slayer
  class Command < Service
    class << self
      def method_added(name)
        return unless name == :call
        super(name)
      end
    end

    def call
      raise NotImplementedError, 'Commands must define method `#call`.'
    end
  end
end
