class NoResultCommand < Slayer::Command
  def call(should_pass: true)
    if should_pass
      return pass
    else
      return flunk
    end
  end
end