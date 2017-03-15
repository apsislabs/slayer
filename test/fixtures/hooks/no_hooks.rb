class NoHooks
  include Slayer::Hook

  def a; end
  def self.a; end

  def b; end
  def self.b; end
end
