class ScopedService < Slayer::Service
  def call
    pass value: true
  end

  def not_call
    pass value: true
  end

  private

    def private_call
      puts "private_call"
    end
end
