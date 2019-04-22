class SkipHooks
  include Slayer::Hook

  hook :wrapper

  skip_hook :a, :b
  singleton_skip_hook :a

  def a; end
  def self.a; end

  def b; end
  def self.b; end

  def c; end
  def self.c; end

  def self.wrapper(_, _instance, wrapper_block)
    wrapper_block.call
    yield
  end
  private_class_method :wrapper
end
