class RaisingService < Slayer::Service
  def self.early_pass
    pass!

    raise "Error After Pass!"
  end

  def self.early_fail
    fail!

    raise "Error After Fail!"
  end
end
