class NoArgCommand < Slayer::Command
  def call
    ok value: 'pass'
  end
end
