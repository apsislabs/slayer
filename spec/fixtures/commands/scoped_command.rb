class ScopedCommand < Slayer::Command
  def call
    ok value: true
  end

  def not_call
    puts 'not call'
  end

  private

  def private_call
    puts 'private_call'
  end
end
