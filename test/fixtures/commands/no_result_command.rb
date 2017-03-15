class NoResultCommand < Slayer::Command
  def call(should_pass: true)
    if should_pass
      return ok
    else
      return err
    end
  end
end
