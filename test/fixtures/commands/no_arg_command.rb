class NoArgCommand < Slayer::Command
  def call
    pass! value: 'pass'
  end
end
