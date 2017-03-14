class MultiplyingService < Slayer::Service
  def inst_mul(x, y)
    m = x*y

    fail! status: :zero if m == 0
    pass! value: x*y
  end

  def self.mul(x, y)
    m = x*y

    fail! status: :zero if m == 0
    pass! value: x*y
  end
end
