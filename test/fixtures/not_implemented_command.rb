# A service which does not properly implement the service interface
class NotImplementedCommand < Slayer::Command
  def call
    return true
  end
end
