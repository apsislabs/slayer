module Slayer::RailsExtensions
  module Form
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      include ActiveModel::Validations

      def validate!
        validatable = respond_to?(:valid?) && respond_to?(:errors)

        raise NotImplementedError unless validatable
        raise FormValidationError, errors unless valid?
      end

      def self.from_params(params, additional_params = {}, root_key: nil)
        params     = params.respond_to?(:to_unsafe_h) ? params.to_unsafe_h : params.to_h
        attr_names = attribute_set.map(&:name)

        attr_hash = params
                      .with_indifferent_access
                      .fetch(root_key, {})
                      .merge(params.slice(*attr_names))
                      .merge(additional_params)

        new(attr_hash)
      end

      def self.from_model(model)
        attr_names = attribute_set.map(&:name)

        attr_hash = attr_names.inject({}) do |n, hash|
          hash[n] = model.public_send(n) if model.respond_to?(n)
        end

        new(attr_hash)
      end

      def self.from_json(json)
        from_params(JSON.parse(json))
      end
    end
  end
end
