class NoDefaultCommand < Slayer::Command
  def call
    pass status: :foo
  end
end