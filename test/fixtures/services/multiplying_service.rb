class MultiplyingService < Slayer::Service
  def inst_mul(x, y)
    m = x * y

    fail! status: :zero if m.zero?
    pass! value: m
  end

  def self.mul(x, y)
    m = x * y

    fail! status: :zero if m.zero?
    pass! value: m
  end
end
