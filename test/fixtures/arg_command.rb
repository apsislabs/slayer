class ArgCommand < Slayer::Command
  def call arg: nil
    unless arg.nil?
      pass! result: arg
    else
      fail! result: arg
    end
  end
end
