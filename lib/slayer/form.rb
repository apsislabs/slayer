require 'virtus'

module Slayer
  class Form
    include Virtus.model
    include RailsExtensions::Form if defined?(Rails)
  end
end
