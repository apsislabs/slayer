class NoArgCommand < Slayer::Command
  def call
    pass! result: 'pass'
  end
end
