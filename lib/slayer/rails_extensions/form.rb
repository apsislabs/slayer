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

          def self.from_params(params, additional_params = {}, root_key: nil)
            params = params.respond_to?(:to_unsafe_h) ? params.to_unsafe_h : params.to_h
            params = params.with_indifferent_access

            attr_names = attribute_set.map(&:name)

            attr_hash = params
              .fetch(root_key, {})
              .merge(params.slice(*attr_names))
              .merge(additional_params)

            new(attr_hash)
          end

          def self.from_model(model)
            attr_names = attribute_set.map(&:name)

            attr_hash = attr_names.inject({}) do |n, hash|
              if model.respond_to?(n)
                hash[n] = model.public_send(n)
              end
            end

            new(attr_hash)
          end

          def self.from_json(json)
            from_params(JSON.parse(json))
          end
        end
      end
    end
  end
end
