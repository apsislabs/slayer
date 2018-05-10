class PassCommand < Slayer::Command
  def call(pass: false)
    flunk! value: pass unless pass
    pass value: pass if pass
  end
end
