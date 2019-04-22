# A command which does not properly implement the command interface
class NotImplementedCommand < Slayer::Command
  def call
    return true
  end
end
