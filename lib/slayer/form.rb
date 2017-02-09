module Slayer
  class Form
    extend ModelAttribute
    include ActiveModel::Validations if defined?(Rails)

    # Internal: Form Class Methods
    class << self
      def from_params(params)
        raise NotImplementedError
      end

      def from_model(model)
        raise NotImplementedError
      end
    end
  end
end
