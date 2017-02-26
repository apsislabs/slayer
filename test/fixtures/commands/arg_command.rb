class ArgCommand < Slayer::Command
  def call(arg: nil)
    if !arg.nil?
      pass! value: arg
    else
      fail! value: arg
    end
  end
end
