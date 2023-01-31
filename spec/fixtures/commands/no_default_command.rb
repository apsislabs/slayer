class NoDefaultCommand < Slayer::Command
  def call
    ok status: :foo
  end
end
