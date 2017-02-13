class ArgCommand < Slayer::Command
  def call arg: nil
    if !arg.nil?
      pass! result: arg
    else
      fail! result: arg
    end
  end
end
