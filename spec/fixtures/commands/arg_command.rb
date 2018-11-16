class ArgCommand < Slayer::Command
  def call(arg: nil)
    flunk! value: arg if arg.nil?

    pass value: arg
  end
end
