class PassCommand < Slayer::Command
  def call(pass:)
    flunk! value: pass if !pass
    pass value: pass if pass
  end
end
