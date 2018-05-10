class PassCommand < Slayer::Command
  def call(pass:)
    flunk! value: pass unless pass
    pass value: pass if pass
  end
end
