class TryingService < Slayer::Service
  def self.try_and_get_5
    v = try! { MultiplyingService.mul(5, 1) }

    pass! value: v
  end

  def self.try_and_get_0
    v = try! { MultiplyingService.mul(5, 0) }

    pass! value: v
  end

  def self.try_and_get_0_with_status(status: nil)
    v = try!(status: status) { MultiplyingService.mul(5, 0) }

    pass! value: v
  end
end
