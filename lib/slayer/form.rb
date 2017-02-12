require 'virtus'
require 'dry-validation'

module Slayer
  class Form
    attr_reader :errors
    include Virtus.model

    class << self
      attr_accessor :_schema

      def validations(&block)
        self._schema = Dry::Validation.Schema(&block)
      end
    end

    def validate!
      result  = self.class._schema.call(self.attributes)
      @errors = result.errors
    end

    def valid?
      validate!
      @errors.nil? || @errors.empty?
    end

    def invalid?
      !valid?
    end
  end
end
