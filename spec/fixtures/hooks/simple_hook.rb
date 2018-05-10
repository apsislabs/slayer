class SimpleHook
  include Slayer::Hook

  hook :wrapper

  def simple; end
  def self.simple; end

  def self.wrapper(_, _instance, wrapper_block)
    wrapper_block.call
    yield
  end
  private_class_method :wrapper
end
