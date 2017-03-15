class SimpleHook
  include Slayer::Hook

  hook :wrapper

  def simple
  end

  def self.simple
  end

  private
  def self.wrapper(_, wrapper_block)
    wrapper_block.call
    yield
  end
end