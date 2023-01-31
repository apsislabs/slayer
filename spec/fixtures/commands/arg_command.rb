class ArgCommand < Slayer::Command
  def call(arg: nil)
    return err value: arg if arg.nil?

    ok value: arg
  end
end
