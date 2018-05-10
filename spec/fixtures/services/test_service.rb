class TestService < Slayer::Service
  class << self
    def pass_5
      pass value: 5
    end

    def flunk_10
      flunk value: 10
    end
  end
end
