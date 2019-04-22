class BoringService < Slayer::Service
  def add(x, y)
    x + y
  end

  def self.add(x, y)
    x + y
  end
end
