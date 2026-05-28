class NoResultCommand < Slayer::Command
  def call(should_pass: true)
    if should_pass
      ok
    else
      err
    end
  end
end
