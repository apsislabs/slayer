module Slayer
  module RailsExtensions
    module Form
      def self.included(base)
        base.class_eval do
          include ActiveModel::Validations

          def validate!
            validatable = respond_to?(:valid?) && respond_to?(:errors)

            raise NotImplementedError unless validatable
            raise FormValidationError, errors unless valid?
          end
        end
      end
    end
  end
end
