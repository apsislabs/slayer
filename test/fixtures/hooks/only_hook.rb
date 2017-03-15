class OnlyHook
  include Slayer::Hook

  hook :wrapper

  only_hook :a, :b

  def a
  end

  def self.a
  end

  def b
  end

  def self.b
  end

  def c
  end

  def self.c
  end

  private
  def self.wrapper(_, wrapper_block)
    wrapper_block.call
    yield
  end
end
