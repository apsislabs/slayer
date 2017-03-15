class ArgCommand < Slayer::Command
  def call(arg: nil)
    if !arg.nil?
      return pass value: arg
    else
      return fail value: arg
    end
  end
end
