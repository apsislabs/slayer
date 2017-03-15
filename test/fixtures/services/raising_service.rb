class RaisingService < Slayer::Service
  def self.early_pass
    pass
    raise 'Error after pass'
  end

  def self.early_halting_flunk
    flunk!
    raise 'Error after flunk!'
  end

  def early_halting_flunk
    flunk!
    raise 'Error after flunk!'
  end

  def self.early_flunk
    flunk
    raise "Error after flunk"
  end

  def early_flunk
    flunk
    raise "Error after flunk"
  end
end
