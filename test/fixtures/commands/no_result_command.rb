class NoResultCommand < Slayer::Command
  def call(should_pass: true)
    if should_pass
      pass!
    else
      fail!
    end
  end
end
