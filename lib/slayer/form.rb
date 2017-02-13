require 'virtus'

module Slayer
  class Form
    include Virtus.model
    include ActiveModel::Validations if defined?(Rails)

    def validate!
      raise NotImplementedError unless self.respond_to?(:valid?)
      raise FormValidationError, errors unless valid?
    end
  end
end
