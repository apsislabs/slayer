class ArgCommand < Slayer::Command
  def call(arg: nil)
    if !arg.nil?
      return ok value: arg
    else
      return err value: arg
    end
  end
end
