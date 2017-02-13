require 'virtus'

module Slayer
  class Form
    include Virtus.model
    include ActiveModel::Validations if defined?(Rails)

    def validate!
      validatable = respond_to?(:valid?) && respond_to?(:errors)

      raise NotImplementedError unless validatable
      raise FormValidationError, errors unless valid?
    end
  end
end
