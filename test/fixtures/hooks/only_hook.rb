class OnlyHook
  include Slayer::Hook

  hook :wrapper

  only_hook :a, :b

  def a; end
  def self.a; end

  def b; end
  def self.b; end

  def c; end
  def self.c; end

  def self.wrapper(_, instance, wrapper_block)
    wrapper_block.call
    yield
  end
  private_class_method :wrapper
end
