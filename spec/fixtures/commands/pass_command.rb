class PassCommand < Slayer::Command
  def call(should_pass: false)
    return err value: should_pass unless should_pass

    pass value: should_pass if should_pass
  end
end
